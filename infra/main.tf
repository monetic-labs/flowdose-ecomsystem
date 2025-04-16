terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "digitalocean" {
  token = var.do_token
}

# Use existing SSH key from DigitalOcean
data "digitalocean_ssh_key" "existing" {
  name = "devin-mbp-14-2023"
}

# Droplet for Backend (Medusa.js)
resource "digitalocean_droplet" "backend" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-backend"
  region   = var.region
  size     = var.backend_droplet_size
  ssh_keys = [data.digitalocean_ssh_key.existing.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker
    
    # Clone the repository
    git clone ${var.repo_url} /opt/flowdose
    cd /opt/flowdose
    
    # Create docker-compose file for backend
    cat > docker-compose.backend.yml <<EOL
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
        ports:
          - "9000:9000"
        restart: always
    EOL
    
    # Deploy the backend
    docker-compose -f docker-compose.backend.yml up -d
  EOF
}

# Droplet for Storefront (Next.js)
resource "digitalocean_droplet" "storefront" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-storefront"
  region   = var.region
  size     = var.storefront_droplet_size
  ssh_keys = [data.digitalocean_ssh_key.existing.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker
    
    # Clone the repository
    git clone ${var.repo_url} /opt/flowdose
    cd /opt/flowdose
    
    # Create docker-compose file for storefront
    cat > docker-compose.storefront.yml <<EOL
    version: '3.8'
    services:
      storefront:
        build:
          context: ./storefront
          dockerfile: Dockerfile
        environment:
          - NODE_ENV=${var.environment}
          - NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://${digitalocean_droplet.backend.ipv4_address}:9000
          - PORT=3000
        ports:
          - "3000:3000"
        restart: always
    EOL
    
    # Deploy the storefront
    docker-compose -f docker-compose.storefront.yml up -d
  EOF
}

# DNS Configuration (if domain exists)
resource "digitalocean_domain" "domain" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

# Main domain A record (if domain exists)
resource "digitalocean_record" "apex" {
  count  = var.domain_name != "" ? 1 : 0
  domain = digitalocean_domain.domain[0].name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.storefront.ipv4_address
  ttl    = 3600
}

# WWW subdomain
resource "digitalocean_record" "www" {
  count  = var.domain_name != "" ? 1 : 0
  domain = digitalocean_domain.domain[0].name
  type   = "CNAME"
  name   = "www"
  value  = "@"
  ttl    = 3600
}

# API subdomain
resource "digitalocean_record" "api" {
  count  = var.domain_name != "" ? 1 : 0
  domain = digitalocean_domain.domain[0].name
  type   = "A"
  name   = var.environment == "staging" ? "api.staging" : "api"
  value  = digitalocean_droplet.backend.ipv4_address
  ttl    = 3600
}

# Output variables for use in scripts
output "backend_ip" {
  value = digitalocean_droplet.backend.ipv4_address
  description = "The IP address of the Backend droplet"
}

output "storefront_ip" {
  value = digitalocean_droplet.storefront.ipv4_address
  description = "The IP address of the Storefront droplet"
}

output "postgres_host" {
  value = var.postgres_host
  description = "The hostname of the PostgreSQL database"
}

output "redis_host" {
  value = var.redis_host
  description = "The hostname of the Redis database"
} 