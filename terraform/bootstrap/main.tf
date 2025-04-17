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
  # spaces_access_id and spaces_secret_key are set in the provider.tf file created by GitHub Actions
}

# Check if the bucket already exists
data "http" "check_bucket" {
  url = "https://flowdose-state-storage.sfo3.digitaloceanspaces.com"
  method = "HEAD"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  bucket_exists = can(data.http.check_bucket.status_code) && data.http.check_bucket.status_code == 200
}

resource "digitalocean_spaces_bucket" "terraform_state" {
  count  = local.bucket_exists ? 0 : 1
  name   = "flowdose-state-storage"
  region = "sfo3"
  acl    = "private"
}

resource "digitalocean_spaces_bucket_object" "readme" {
  count        = local.bucket_exists ? 0 : 1
  region       = "sfo3"
  bucket       = local.bucket_exists ? "flowdose-state-storage" : digitalocean_spaces_bucket.terraform_state[0].name
  key          = "README.md"
  content      = "# Terraform State for Flowdose\nThis bucket manages Terraform state for the Flowdose project.\n"
  content_type = "text/markdown"
}

output "bucket_name" {
  value       = local.bucket_exists ? "flowdose-state-storage" : try(digitalocean_spaces_bucket.terraform_state[0].name, "flowdose-state-storage")
  description = "The name of the Spaces bucket for Terraform state"
}

output "bucket_endpoint" {
  value       = "https://flowdose-state-storage.sfo3.digitaloceanspaces.com"
  description = "The endpoint URL of the Spaces bucket"
} 