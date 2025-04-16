variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "environment" {
  description = "Environment (staging or production)"
  type        = string
  default     = "production"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sfo3"
}

variable "backend_droplet_size" {
  description = "Size of the backend droplet"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "storefront_droplet_size" {
  description = "Size of the storefront droplet"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/backpack-fux/flowdose-ecomsystem.git"
}

variable "database_url" {
  description = "PostgreSQL connection URL"
  type        = string
  sensitive   = true
}

variable "redis_url" {
  description = "Redis connection URL"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for the application (leave empty if not using custom domain)"
  type        = string
  default     = ""
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "redis_host" {
  description = "Redis host"
  type        = string
} 