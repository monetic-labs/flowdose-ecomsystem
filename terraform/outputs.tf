# Output variables for use in scripts and GitHub Actions
output "backend_ip" {
  value       = digitalocean_droplet.backend.ipv4_address
  description = "The IP address of the Backend droplet"
}

output "storefront_ip" {
  value       = digitalocean_droplet.storefront.ipv4_address
  description = "The IP address of the Storefront droplet"
}

output "backend_url" {
  value       = var.domain_name != "" ? "https://admin.${var.domain_name}" : "http://${digitalocean_droplet.backend.ipv4_address}:9000"
  description = "The URL for the backend API/admin"
}

output "storefront_url" {
  value       = var.domain_name != "" ? "https://store.${var.domain_name}" : "http://${digitalocean_droplet.storefront.ipv4_address}:3000"
  description = "The URL for the storefront"
}

output "postgres_host" {
  value       = var.postgres_host
  description = "The hostname of the PostgreSQL database"
}

output "redis_host" {
  value       = var.redis_host
  description = "The hostname of the Redis database"
} 