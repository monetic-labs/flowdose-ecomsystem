variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content (required for Droplet access)"
  type        = string
  
  validation {
    condition     = length(var.ssh_public_key) > 0 && can(regex("^ssh-[a-z0-9]+ [A-Za-z0-9+/=]+", var.ssh_public_key))
    error_message = "SSH public key must be a valid OpenSSH public key format starting with 'ssh-rsa', 'ssh-ed25519', etc."
  }
}

variable "ssh_private_key" {
  description = "SSH private key content (required for provisioning)"
  type        = string
  sensitive   = true
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

variable "admin_email_for_certs" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
  default     = "admin@flowdose.xyz"
}

variable "jwt_secret" {
  description = "Secret key for JWT authentication"
  type        = string
  sensitive   = true
}

variable "cookie_secret" {
  description = "Secret key for cookie encryption"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin user password"
  type        = string
  sensitive   = true
}

variable "publishable_key" {
  description = "Medusa publishable key"
  type        = string
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "redis_host" {
  description = "Redis host"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file (for local testing only)"
  type        = string
  default     = ""
} 