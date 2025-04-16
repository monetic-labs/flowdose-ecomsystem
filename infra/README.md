# Flowdose Ecomsystem Infrastructure

This directory contains Terraform code to deploy the Flowdose Ecomsystem infrastructure on DigitalOcean.

## Architecture

The infrastructure consists of:

1. **Backend Droplet** - Hosting Medusa.js API service
2. **Storefront Droplet** - Hosting Next.js frontend service
3. **PostgreSQL Database** - Managed database for storing application data
4. **Redis Database** - Managed database for caching and queues
5. **Spaces Bucket** - Object storage for media files

## Prerequisites

- DigitalOcean account with API token
- Terraform installed locally
- SSH key for accessing Droplets
- `doctl` CLI installed and authenticated

## Deployment

The deployment script will create all necessary infrastructure components.

### Using the deploy script

```bash
# Make the script executable
chmod +x deploy.sh

# Deploy to production
./deploy.sh -t YOUR_DO_TOKEN

# Deploy to staging
./deploy.sh -e staging -t YOUR_DO_TOKEN

# Deploy with a custom domain
./deploy.sh -t YOUR_DO_TOKEN -d yourdomain.com
```

### Manual deployment

If you prefer to run Terraform commands manually:

1. Create a `terraform.tfvars` file with your configuration:

```
do_token = "your_do_token"
environment = "production"
region = "sfo3"
database_url = "postgresql://user:password@host:port/db"
redis_url = "redis://user:password@host:port"
postgres_host = "postgres-host"
redis_host = "redis-host"
domain_name = "yourdomain.com"
```

2. Initialize and apply Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Environment Variables

After deployment, you'll need to set environment variables for your applications. The deployment outputs all necessary IPs and connection details.

### Backend Environment Variables

Create a `.env.production` (or `.env.staging`) file in the backend directory:

```
DATABASE_URL=your_postgres_connection_string
REDIS_URL=your_redis_connection_string
NODE_ENV=production
PORT=9000
```

### Storefront Environment Variables

Create a `.env.local` file in the storefront directory:

```
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://backend_ip:9000
NODE_ENV=production
```

## SSL Configuration

To configure SSL for your domains, SSH into your Droplets and set up Certbot:

```bash
ssh root@droplet_ip

# Install Certbot
apt-get update
apt-get install -y certbot

# Obtain certificates
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

Then update your web server configuration to use the certificates located at `/etc/letsencrypt/live/yourdomain.com/`.

## Infrastructure Maintenance

### Scaling

To scale your infrastructure, modify the Droplet sizes in `variables.tf` or directly in your `terraform.tfvars` file:

```
backend_droplet_size = "s-4vcpu-8gb"
storefront_droplet_size = "s-4vcpu-8gb"
```

### Backup

The managed databases include automatic backups. For Droplets, consider setting up regular snapshots. 