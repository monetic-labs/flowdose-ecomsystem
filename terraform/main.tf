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

# Always fetch all SSH keys to ensure we have access to them
data "digitalocean_ssh_keys" "all" {}

# Local variables
locals {
  # Create a list of key IDs to use for droplets - we'll use all existing keys to ensure we don't lose access
  ssh_key_ids = [for key in data.digitalocean_ssh_keys.all.ssh_keys : key.id]
}

# Droplet for Backend (Medusa.js)
resource "digitalocean_droplet" "backend" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-backend"
  region   = var.region
  size     = var.backend_droplet_size
  ssh_keys = local.ssh_key_ids

  # Increased timeout for initial setup
  provisioner "remote-exec" {
    inline = ["sleep 10"] # Give docker time to start
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker

    # Create project directory
    mkdir -p /opt/flowdose

    # Set up docker network if it doesn't exist
    docker network create flowdose-network || true

    # Create placeholder directory structure
    mkdir -p /opt/flowdose/backend
    mkdir -p /opt/flowdose/data/caddy_data
    mkdir -p /opt/flowdose/data/caddy_config

    # Create a simple status file to indicate provisioning is complete
    echo "provisioned: $(date)" > /opt/flowdose/backend-provisioned.txt
  EOF
}

# Droplet for Storefront (Next.js)
resource "digitalocean_droplet" "storefront" {
  image    = "docker-20-04"
  name     = "${var.environment}-flowdose-storefront"
  region   = var.region
  size     = var.storefront_droplet_size
  ssh_keys = local.ssh_key_ids

  # Increased timeout for initial setup
  provisioner "remote-exec" {
    inline = ["sleep 10"] # Give docker time to start
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker

    # Create project directory
    mkdir -p /opt/flowdose

    # Set up docker network if it doesn't exist
    docker network create flowdose-network || true

    # Create placeholder directory structure
    mkdir -p /opt/flowdose/storefront
    mkdir -p /opt/flowdose/data/caddy_data
    mkdir -p /opt/flowdose/data/caddy_config

    # Create a simple status file to indicate provisioning is complete
    echo "provisioned: $(date)" > /opt/flowdose/storefront-provisioned.txt
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