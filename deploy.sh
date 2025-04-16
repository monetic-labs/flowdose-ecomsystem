#!/bin/bash

# Help function
function show_help {
  echo "Usage: ./deploy.sh [options]"
  echo "Options:"
  echo "  -e, --environment ENV    Set environment (staging or production)"
  echo "  -t, --token TOKEN        DigitalOcean API token"
  echo "  -d, --domain DOMAIN      Domain name (optional)"
  echo "  -k, --ssh-key PATH       Path to SSH public key (default: ~/.ssh/digitalocean_key.pub)"
  echo "  -h, --help               Display this help message"
  exit 0
}

# Default values
ENVIRONMENT="production"
DOMAIN=""
SSH_KEY_PATH="$HOME/.ssh/digitalocean_key.pub"

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
    -k|--ssh-key)
      SSH_KEY_PATH="$2"
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

# Check SSH key
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "Error: SSH public key file not found at $SSH_KEY_PATH"
  exit 1
fi

SSH_PUBLIC_KEY=$(cat "$SSH_KEY_PATH")

# Get database information
POSTGRES_DB_ID=$(doctl databases list --format ID,Name --no-header | grep postgres-db | awk '{print $1}')
if [ -z "$POSTGRES_DB_ID" ]; then
  echo "Error: PostgreSQL database not found."
  exit 1
fi

REDIS_DB_ID=$(doctl databases list --format ID,Name --no-header | grep redis-db | awk '{print $1}')
if [ -z "$REDIS_DB_ID" ]; then
  echo "Error: Redis database not found."
  exit 1
fi

# Get connection strings
POSTGRES_CONNECTION=$(doctl databases connection $POSTGRES_DB_ID --format URI --no-header)
REDIS_CONNECTION=$(doctl databases connection $REDIS_DB_ID --format URI --no-header)

POSTGRES_HOST=$(doctl databases connection $POSTGRES_DB_ID --format Host --no-header)
REDIS_HOST=$(doctl databases connection $REDIS_DB_ID --format Host --no-header)

# Create terraform.tfvars file
cat > terraform.tfvars <<EOL
do_token = "$DO_TOKEN"
environment = "$ENVIRONMENT"
region = "sfo3"
database_url = "$POSTGRES_CONNECTION"
redis_url = "$REDIS_CONNECTION"
postgres_host = "$POSTGRES_HOST"
redis_host = "$REDIS_HOST"
domain_name = "$DOMAIN"
ssh_public_key = "$SSH_PUBLIC_KEY"
EOL

# Initialize and apply Terraform
terraform init
terraform plan
echo "Starting deployment for $ENVIRONMENT environment..."
terraform apply -auto-approve

# Display output
echo "Deployment completed!"
terraform output 