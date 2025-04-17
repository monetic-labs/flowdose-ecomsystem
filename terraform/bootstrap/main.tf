terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_spaces_bucket" "terraform_state" {
  name   = "flowdose-terraform-state"
  region = "sfo3"
  acl    = "private"
}

resource "digitalocean_spaces_bucket_object" "readme" {
  region       = digitalocean_spaces_bucket.terraform_state.region
  bucket       = digitalocean_spaces_bucket.terraform_state.name
  key          = "README.md"
  content      = "# Terraform State for Flowdose\nThis bucket manages Terraform state for the Flowdose project.\n"
  content_type = "text/markdown"
}

output "bucket_name" {
  value       = digitalocean_spaces_bucket.terraform_state.name
  description = "The name of the Spaces bucket for Terraform state"
}

output "bucket_endpoint" {
  value       = "https://${digitalocean_spaces_bucket.terraform_state.bucket_domain_name}"
  description = "The endpoint URL of the Spaces bucket"
} 