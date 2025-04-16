#!/bin/bash

# Help function
function show_help {
  echo "Usage: ./deploy.sh [options]"
  echo "Options:"
  echo "  -e, --environment ENV    Set environment (staging or production)"
  echo "  -t, --token TOKEN        DigitalOcean API token"
  echo "  -d, --domain DOMAIN      Domain name (optional)"
  echo "  -h, --help               Display this help message"
  exit 0
}

# Default values
ENVIRONMENT="production"
DOMAIN=""
POSTGRES_DB_ID="4c10f92a-91d7-4a8e-b87b-beceae5f3cba"  # Flowdose PostgreSQL database ID
REDIS_DB_ID="71245127-aa74-4d1c-bd90-5830aea9bb69"     # Flowdose Redis database ID

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -t|--token)
      DO_TOKEN="$2"
      shift 2
      ;;
    -d|--domain)
      DOMAIN="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

# Check required parameters
if [ -z "$DO_TOKEN" ]; then
  echo "Error: DigitalOcean API token is required. Use -t or --token."
  exit 1
fi

# Get database information
echo "Getting database connection information..."

# Get connection strings
POSTGRES_CONNECTION=$(doctl databases connection $POSTGRES_DB_ID --format URI --no-header)
REDIS_CONNECTION=$(doctl databases connection $REDIS_DB_ID --format URI --no-header)

POSTGRES_HOST=$(doctl databases connection $POSTGRES_DB_ID --format Host --no-header)
REDIS_HOST=$(doctl databases connection $REDIS_DB_ID --format Host --no-header)

# Create terraform.tfvars file
cat > terraform.tfvars <<EOL
do_token = "$DO_TOKEN"
ssh_public_key = "$(cat ~/.ssh/digitalocean_key.pub)"
environment = "$ENVIRONMENT"
region = "sfo3"
database_url = "$POSTGRES_CONNECTION"
redis_url = "$REDIS_CONNECTION"
postgres_host = "$POSTGRES_HOST"
redis_host = "$REDIS_HOST"
domain_name = "$DOMAIN"
EOL

# Initialize and apply Terraform
terraform init
terraform plan
echo "Starting deployment for $ENVIRONMENT environment..."
terraform apply -auto-approve

# Display output
echo "Deployment completed!"
terraform output 