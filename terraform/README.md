# Flowdose Infrastructure as Code

This directory contains the Terraform configurations for the Flowdose infrastructure.

## Directory Structure

```
terraform/
├── bootstrap/         # One-time setup for Terraform state
│   ├── main.tf        # Creates the Spaces bucket for state
│   └── variables.tf   # Variables for bootstrap
├── backend.tf         # Remote state configuration
├── main.tf            # Main infrastructure definition
├── outputs.tf         # Output values
└── variables.tf       # Input variables
```

## Deployment Flow

The infrastructure is deployed in two phases:

1. **Bootstrap Phase** (One-time Setup)
   - Creates a DigitalOcean Spaces bucket for Terraform state
   - Run via GitHub Actions workflow: `terraform-bootstrap.yml`

2. **Infrastructure Deployment Phase**
   - Creates all infrastructure resources (droplets, DNS, etc.)
   - Run via GitHub Actions workflow: `terraform-infrastructure.yml`

## Required Variables

The following variables must be set in CI/CD secrets:

- `DO_API_TOKEN`: DigitalOcean API token
- `DO_SPACES_ACCESS_KEY`: Spaces access key
- `DO_SPACES_SECRET_KEY`: Spaces secret key
- `DO_SSH_PRIVATE_KEY`: SSH private key for accessing droplets
- `DO_SSH_PUBLIC_KEY`: SSH public key for droplet provisioning
- `JWT_SECRET`: Secret for JWT tokens
- `COOKIE_SECRET`: Secret for cookies
- `ADMIN_PASSWORD`: Password for the Medusa admin user

## Local Development

To deploy from your local machine:

1. Create a `terraform.tfvars` file with the required variables:

```hcl
do_token         = "your_do_api_token"
database_url     = "your_database_url"
redis_url        = "your_redis_url"
domain_name      = "your_domain.com"  # Optional
```

2. Run the standard Terraform commands:

```shell
terraform init -backend-config="access_key=your_spaces_access_key" -backend-config="secret_key=your_spaces_secret_key"
terraform plan
terraform apply
```

## Remote State

The Terraform state is stored in a DigitalOcean Spaces bucket named `flowdose-terraform-state`. This allows multiple team members to safely collaborate on infrastructure changes. 