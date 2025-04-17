# Output variables for use in scripts and GitHub Actions
output "backend_ip" {
  value       = digitalocean_droplet.backend.ipv4_address
  description = "The public IP address of the backend server"
}

output "storefront_ip" {
  value       = digitalocean_droplet.storefront.ipv4_address
  description = "The public IP address of the storefront server"
}

output "admin_domain" {
  value       = var.domain_name != "" ? "admin.${var.domain_name}" : digitalocean_droplet.backend.ipv4_address
  description = "The domain or IP for accessing the admin panel"
}

output "store_domain" {
  value       = var.domain_name != "" ? "store.${var.domain_name}" : digitalocean_droplet.storefront.ipv4_address
  description = "The domain or IP for accessing the storefront"
}

output "provisioning_complete" {
  value       = "${timestamp()}"
  description = "Timestamp to indicate when provisioning completed"
}

output "environment" {
  value       = var.environment
  description = "The current deployment environment"
}

output "postgres_host" {
  value       = var.postgres_host
  description = "The hostname of the PostgreSQL database"
}

output "redis_host" {
  value       = var.redis_host
  description = "The hostname of the Redis database"
} 