terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Since we can't reliably check if the bucket exists, we'll use a variable
variable "skip_bucket_creation" {
  type        = bool
  default     = false
  description = "Set to true if the bucket already exists"
}

# Provider is configured in provider-creds.tf

resource "digitalocean_spaces_bucket" "terraform_state" {
  count  = var.skip_bucket_creation ? 0 : 1
  name   = "flowdose-state-storage"
  region = "sfo3"
  acl    = "private"
}

resource "digitalocean_spaces_bucket_object" "readme" {
  count        = var.skip_bucket_creation ? 0 : 1
  region       = "sfo3"
  bucket       = var.skip_bucket_creation ? "flowdose-state-storage" : digitalocean_spaces_bucket.terraform_state[0].name
  key          = "README.md"
  content      = "# Terraform State for Flowdose\nThis bucket manages Terraform state for the Flowdose project.\n"
  content_type = "text/markdown"
}

output "bucket_name" {
  value       = var.skip_bucket_creation ? "flowdose-state-storage" : try(digitalocean_spaces_bucket.terraform_state[0].name, "flowdose-state-storage")
  description = "The name of the Spaces bucket for Terraform state"
}

output "bucket_endpoint" {
  value       = "https://flowdose-state-storage.sfo3.digitaloceanspaces.com"
  description = "The endpoint URL of the Spaces bucket"
} 