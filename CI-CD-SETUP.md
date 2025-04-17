# Flowdose CI/CD with Terraform Integration

This document explains the CI/CD setup for the Flowdose ecosystem using GitHub Actions and Terraform.

## Overview

The deployment process has three main components:

1. **Bootstrap** (one-time setup): Creates the Terraform state storage
2. **Infrastructure Deployment** (Terraform): Manages servers, databases, and networks
3. **Application Deployment** (Docker): Manages the application code and containers

## Setup Process

### 1. Bootstrap Terraform State

Before you can deploy infrastructure, you need to set up the Terraform state storage:

1. Add your DigitalOcean API token as a GitHub secret (`DO_API_TOKEN`)
2. Run the `Terraform Bootstrap` workflow from the GitHub Actions tab
3. Create Spaces access keys in the DigitalOcean console for the created bucket
4. Add the Spaces keys as GitHub secrets (`DO_SPACES_ACCESS_KEY` and `DO_SPACES_SECRET_KEY`)

### 2. Deploy Infrastructure

Once bootstrap is complete, you can deploy your infrastructure:

1. Run the `Terraform Infrastructure Deployment` workflow
2. This will create/update all infrastructure resources
3. Application deployment will trigger automatically after successful infrastructure deployment

## Required GitHub Secrets

You must configure these secrets in your GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `DO_API_TOKEN` | DigitalOcean API token with write access |
| `DO_SPACES_ACCESS_KEY` | Access key for DigitalOcean Spaces (for Terraform state) |
| `DO_SPACES_SECRET_KEY` | Secret key for DigitalOcean Spaces (for Terraform state) |
| `DO_SSH_PRIVATE_KEY` | SSH private key for server access |
| `DO_SSH_PUBLIC_KEY` | SSH public key for server provisioning |
| `JWT_SECRET` | Secret for JWT tokens |
| `COOKIE_SECRET` | Secret for cookies |

## Workflow Details

### Bootstrap Workflow (`.github/workflows/terraform-bootstrap.yml`)

This workflow:
- Is triggered manually when needed
- Creates a Spaces bucket for storing Terraform state
- Provides access key creation instructions

### Infrastructure Deployment (`.github/workflows/terraform-infrastructure.yml`)

Triggered by:
- Changes to Terraform configurations
- Manual trigger via GitHub UI

This workflow:
1. Initializes Terraform with the remote backend on DigitalOcean Spaces
2. Validates and plans infrastructure changes
3. Applies changes to DigitalOcean infrastructure
4. Outputs the server IPs for the application deployment

### Application Deployment (`.github/workflows/do-droplet-deploy.yml`)

Triggered by:
- Changes to application code
- After a successful infrastructure deployment

This workflow:
1. Reads server IPs from Terraform state
2. Connects to servers via SSH
3. Pulls latest code and rebuilds Docker containers
4. Restarts the application services

## Terraform State Management

Terraform state is stored in a DigitalOcean Spaces bucket:
- Bucket: `flowdose-terraform-state` (created by bootstrap workflow)
- Key: `flowdose/terraform.tfstate`

## Manual Deployment

For manual deployments, you can:

1. Infrastructure: Use the "Run workflow" button on the Terraform workflow in GitHub
2. Application: Push a small change to the `deploy-trigger` file to trigger a deployment

## Troubleshooting

- **Infrastructure Changes Not Applied**: Check Terraform workflow logs for errors
- **Application Not Deploying**: Verify SSH access to the servers and Docker permissions
- **State Issues**: You may need to manually import resources if they were created outside Terraform

## Migration Path from Manual to CI/CD

If you've been managing infrastructure manually:

1. Run the bootstrap workflow to create the Terraform state bucket
2. Use `terraform import` commands to bring existing resources under management
3. Set up the required GitHub Secrets
4. Push changes to trigger the workflows 