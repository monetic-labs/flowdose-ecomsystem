terraform {
  backend "s3" {
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    bucket                      = "flowdose-terraform-state"
    key                         = "flowdose/terraform.tfstate"
    region                      = "us-east-1" # Required but not used for DO
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = false # Set to true for MinIO/custom S3
  }
} 