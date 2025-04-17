terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0.0"
  
  # Backend configuration is in backend.tf
}

provider "digitalocean" {
  token = var.do_token
}

# Use existing SSH key from DigitalOcean
data "digitalocean_ssh_key" "existing" {
  name = "flowdose-deploy-key"
}

# Droplet for Backend (Medusa.js)
resource "digitalocean_droplet" "backend" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-backend"
  region   = var.region
  size     = var.backend_droplet_size
  ssh_keys = [data.digitalocean_ssh_key.existing.id]

  # Increased timeout for Caddy setup
  provisioner "remote-exec" {
    inline = ["sleep 10"] # Give docker time to start
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key_path)
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker

    # Clone the repository if it doesn't exist
    if [ ! -d "/opt/flowdose" ]; then
      git clone ${var.repo_url} /opt/flowdose
    fi
    cd /opt/flowdose
    git pull # Ensure latest code

    # Create Caddyfile for backend
    cat > /opt/flowdose/Caddyfile_backend <<EOL
    admin.${var.domain_name} {
        reverse_proxy backend:9000
        tls ${var.admin_email_for_certs} # Email for Let's Encrypt
    }
    EOL

    # Create docker-compose file for backend with Caddy
    cat > /opt/flowdose/docker-compose.backend.yml <<EOL
    version: '3.8'
    services:
      backend:
        build:
          context: ./backend
          dockerfile: Dockerfile
        environment:
          - NODE_ENV=${var.environment}
          - DATABASE_URL=${var.database_url}
          - REDIS_URL=${var.redis_url}
          - PORT=9000
          # Updated CORS settings with HTTPS and new domains
          - ADMIN_CORS=https://admin.${var.domain_name},https://store.${var.domain_name}
          - STORE_CORS=https://store.${var.domain_name}
          - AUTH_CORS=https://admin.${var.domain_name},https://store.${var.domain_name}
          # Auth secrets
          - JWT_SECRET=${var.jwt_secret}
          - COOKIE_SECRET=${var.cookie_secret}
          # Admin account
          - MEDUSA_ADMIN_EMAIL=admin@flowdose.xyz
          - MEDUSA_ADMIN_PASSWORD=${var.admin_password}
          # Publishable Key
          - MEDUSA_PUBLISHABLE_KEY=${var.publishable_key}
        restart: always

      caddy:
        image: caddy:2-alpine
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - ./Caddyfile_backend:/etc/caddy/Caddyfile
          - caddy_data:/data
          - caddy_config:/config
        depends_on:
          - backend

    volumes:
      caddy_data:
      caddy_config:
    EOL

    # Deploy the backend stack
    docker-compose -f /opt/flowdose/docker-compose.backend.yml up -d --remove-orphans
  EOF
}

# Droplet for Storefront (Next.js)
resource "digitalocean_droplet" "storefront" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-storefront"
  region   = var.region
  size     = var.storefront_droplet_size
  ssh_keys = [data.digitalocean_ssh_key.existing.id]

  # Increased timeout for Caddy setup
  provisioner "remote-exec" {
    inline = ["sleep 10"] # Give docker time to start
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key_path)
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker

    # Clone the repository if it doesn't exist
    if [ ! -d "/opt/flowdose" ]; then
      git clone ${var.repo_url} /opt/flowdose
    fi
    cd /opt/flowdose
    git pull # Ensure latest code

    # Create Caddyfile for storefront
    cat > /opt/flowdose/Caddyfile_storefront <<EOL
    store.${var.domain_name} {
        reverse_proxy storefront:3000
        tls ${var.admin_email_for_certs} # Email for Let's Encrypt
    }
    EOL

    # Create docker-compose file for storefront with Caddy
    cat > /opt/flowdose/docker-compose.storefront.yml <<EOL
    version: '3.8'
    services:
      storefront:
        build:
          context: ./storefront
          dockerfile: Dockerfile
        environment:
          - NODE_ENV=${var.environment}
          # Use HTTPS and the admin subdomain for backend URL
          - NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://admin.${var.domain_name}
          - NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${var.publishable_key}
          - NEXT_PUBLIC_BASE_URL=https://store.${var.domain_name}
          - PORT=3000
        restart: always

      caddy:
        image: caddy:2-alpine
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - ./Caddyfile_storefront:/etc/caddy/Caddyfile
          - caddy_data:/data
          - caddy_config:/config
        depends_on:
          - storefront

    volumes:
      caddy_data:
      caddy_config:
    EOL

    # Deploy the storefront stack
    docker-compose -f /opt/flowdose/docker-compose.storefront.yml up -d --remove-orphans
  EOF
}

# DNS Configuration
resource "digitalocean_domain" "domain" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

# Storefront subdomain DNS record
resource "digitalocean_record" "store" {
  count  = var.domain_name != "" ? 1 : 0
  domain = digitalocean_domain.domain[0].name
  type   = "A"
  name   = "store" # Subdomain for the storefront
  value  = digitalocean_droplet.storefront.ipv4_address
  ttl    = 1800
}

# Backend/Admin subdomain DNS record
resource "digitalocean_record" "admin" {
  count  = var.domain_name != "" ? 1 : 0
  domain = digitalocean_domain.domain[0].name
  type   = "A"
  name   = "admin" # Subdomain for the backend/admin
  value  = digitalocean_droplet.backend.ipv4_address
  ttl    = 1800
} 