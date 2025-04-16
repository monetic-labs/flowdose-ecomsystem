# DigitalOcean Deployment

This project is set up to automatically deploy to DigitalOcean droplets using GitHub Actions.

## Infrastructure

The infrastructure consists of:

- **Backend Droplet**: 137.184.81.212 (Port 9000)
- **Storefront Droplet**: 143.110.144.17 (Port 3000)
- **PostgreSQL Database**: postgres-flowdose-do-user-17309531-0.k.db.ondigitalocean.com
- **Redis Database**: redis-flowdose-do-user-17309531-0.k.db.ondigitalocean.com

## Automated Deployment

Deployments are automated via GitHub Actions. The workflow is defined in `.github/workflows/do-droplet-deploy.yml`.

The workflow does the following:
1. Triggers when changes are pushed to `master` branch (for backend, storefront, or the workflow itself)
2. SSHs into both droplets
3. Pulls the latest code
4. Rebuilds and restarts the Docker containers

## Manual Deployment

If needed, you can deploy manually by SSHing into the droplets:

```bash
# For backend
ssh -i ~/.ssh/digitalocean_key root@137.184.81.212
cd /opt/flowdose
git pull
docker-compose -f docker-compose.backend.yml down
docker-compose -f docker-compose.backend.yml build --no-cache
docker-compose -f docker-compose.backend.yml up -d

# For storefront
ssh -i ~/.ssh/digitalocean_key root@143.110.144.17
cd /opt/flowdose
git pull
docker-compose -f docker-compose.storefront.yml down
docker-compose -f docker-compose.storefront.yml build --no-cache
docker-compose -f docker-compose.storefront.yml up -d
```

## Triggering a Deployment

To trigger a deployment without changing backend or storefront code, update the timestamp in the `deploy-trigger` file and commit.

## Infrastructure Components

The Flowdose Ecomsystem consists of the following components:

1. **Backend Service (Medusa.js)** - API and business logic
2. **Storefront Service (Next.js)** - User-facing web application
3. **PostgreSQL Database** - Primary data store
4. **Redis** - Caching and session management
5. **MeiliSearch** - Search functionality
6. **Bucket (Object Storage)** - File storage for media
7. **Console** - Admin interface

## Deployment Architecture

![Deployment Architecture](../architecture/diagrams/do-deployment.png)

### Services Configuration

| Service    | Plan      | Instances | Environment | Resource Allocation |
|------------|-----------|-----------|------------|---------------------|
| Backend    | Basic     | 1-3       | Node.js    | 1vCPU, 1GB RAM      |
| Storefront | Basic     | 1-3       | Node.js    | 1vCPU, 1GB RAM      |
| PostgreSQL | Managed DB| 1         | N/A        | 1vCPU, 1GB RAM      |
| Redis      | Managed DB| 1         | N/A        | 1vCPU, 1GB RAM      |
| MeiliSearch| Basic     | 1         | Node.js    | 1vCPU, 1GB RAM      |
| Bucket     | Spaces    | N/A       | N/A        | Pay-as-you-go       |

## Deployment Process

### Prerequisites

1. DigitalOcean account with appropriate permissions
2. DigitalOcean CLI (`doctl`) installed and authenticated
3. Docker installed for local testing
4. GitHub repository set up with CI/CD workflows

### Step 1: Create DigitalOcean Resources

```bash
# Authenticate with DigitalOcean
doctl auth init

# Create App Platform project
doctl apps create --spec app-spec.yaml

# Create managed databases
doctl databases create postgres-db --engine pg --size db-s-1vcpu-1gb --region nyc1 --num-nodes 1
doctl databases create redis-db --engine redis --size db-s-1vcpu-1gb --region nyc1 --num-nodes 1

# Create Spaces bucket
doctl spaces create flowdose-media --region nyc3
```

### Step 2: Set Up App Specification

Create an `app-spec.yaml` file in the project root:

```yaml
name: flowdose-ecomsystem
region: nyc
services:
  - name: backend
    github:
      repo: your-org/flowdose-ecomsystem
      branch: master
      deploy_on_push: true
    source_dir: backend
    dockerfile_path: backend/Dockerfile
    http_port: 9000
    instance_count: 1
    instance_size_slug: basic-xs
    routes:
      - path: /api
    envs:
      - key: NODE_ENV
        scope: RUN_TIME
        value: production
      - key: DATABASE_URL
        scope: RUN_TIME
        value: ${postgres.DATABASE_URL}
      - key: REDIS_URL
        scope: RUN_TIME
        value: ${redis.DATABASE_URL}
      # Add all other environment variables here

  - name: storefront
    github:
      repo: your-org/flowdose-ecomsystem
      branch: master
      deploy_on_push: true
    source_dir: storefront
    dockerfile_path: storefront/Dockerfile
    http_port: 3000
    instance_count: 1
    instance_size_slug: basic-xs
    routes:
      - path: /
    envs:
      - key: NODE_ENV
        scope: RUN_TIME
        value: production
      - key: NEXT_PUBLIC_MEDUSA_BACKEND_URL
        scope: RUN_TIME
        value: ${backend.INTERNAL_URL}
      # Add all other environment variables here

databases:
  - name: postgres
    engine: PG
    production: true
    cluster_name: flowdose-postgres
    
  - name: redis
    engine: REDIS
    production: true
    cluster_name: flowdose-redis
```

### Step 3: Set Up Dockerfiles

Create a Dockerfile for the backend:

```dockerfile
FROM oven/bun:1.1.10

WORKDIR /app
COPY . .

# Install dependencies
RUN bun install

# Build the application
RUN bun run build

# Create necessary directories
RUN mkdir -p .medusa/server

# Copy medusa-config.js to the .medusa/server directory
RUN cp medusa-config.js .medusa/server/

# Expose the application port
EXPOSE 9000

# Start the application
CMD ["bun", "start"]
```

Create a Dockerfile for the storefront:

```dockerfile
FROM oven/bun:1.1.10

WORKDIR /app
COPY . .

# Install dependencies
RUN bun install

# Build the application
RUN bun run build

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["bun", "run", "start"]
```

### Step 4: Set Up CI/CD

Create GitHub Actions workflows for deployment:

`.github/workflows/do-deploy.yml`:

```yaml
name: Deploy to DigitalOcean

on:
  push:
    branches:
      - master
    paths:
      - 'backend/**'
      - 'storefront/**'
      - '.github/workflows/do-deploy.yml'
      - 'deploy-trigger'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Install doctl
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
      
      - name: Deploy App to DO
        run: doctl apps update ${{ secrets.DO_APP_ID }} --spec app-spec.yaml
```

### Step 5: Environment Configuration

Set up environment variables for each environment:

1. **Local Development**: Use `.env` files in each service directory
2. **Staging**: Configure variables in DigitalOcean App Platform for staging environment
3. **Production**: Configure variables in DigitalOcean App Platform for production environment

See [Environment Switching](../environments/switching.md) for details on switching between environments.

### Step 6: Database Migrations

Configure the backend service to run migrations automatically on deployment:

Add to the backend Dockerfile:

```dockerfile
# Run migrations before starting the application
CMD ["bun", "run", "migrate", "&&", "bun", "start"]
```

Or use a pre-deploy script in DO App Platform:

```yaml
services:
  - name: backend
    # ... other configurations
    pre_deploy_command: bun run migrate
```

## Scaling Plan

### Horizontal Scaling

The DigitalOcean App Platform allows horizontal scaling by increasing the instance count:

```yaml
services:
  - name: backend
    # ... other configurations
    instance_count: 3
```

### Vertical Scaling

Upgrade service plans as needed:

```yaml
services:
  - name: backend
    # ... other configurations
    instance_size_slug: basic-s # Upgrade from basic-xs
```

## Monitoring and Logging

1. **App Platform Metrics**: Basic monitoring is provided out of the box
2. **DigitalOcean Monitoring**: Set up alerts for resource utilization
3. **Application Logs**: Available in DigitalOcean App Platform dashboard
4. **External Monitoring**: Consider setting up Datadog or New Relic for advanced monitoring

## Rollback Strategy

In case of deployment failures:

1. **Automatic Rollbacks**: App Platform will automatically roll back failed deployments
2. **Manual Rollbacks**: Use the DigitalOcean dashboard to revert to previous deployments
3. **Code Reversion**: Revert the problematic commit and push to trigger a new deployment

## Backup Strategy

1. **Database Backups**: DigitalOcean Managed Databases provide automated backups
2. **Manual Backups**: Regularly export data for additional safety
3. **Media Backups**: Set up Spaces backup for the bucket

## Cost Estimation

| Component          | Plan           | Monthly Cost |
|--------------------|----------------|--------------|
| Backend Service    | Basic-xs       | $12          |
| Storefront Service | Basic-xs       | $12          |
| PostgreSQL         | 1GB            | $15          |
| Redis              | 1GB            | $15          |
| MeiliSearch        | Basic-xs       | $12          |
| Spaces (Bucket)    | 250GB          | $5           |
| **Total**          |                | **$71**      |

## Security Considerations

1. **DO App Platform Security**: Security is managed by DigitalOcean
2. **Database Security**: Use private networking and strong passwords
3. **API Security**: Implement rate limiting and proper authentication
4. **Environment Variables**: Never commit sensitive information to the repo

## Next Steps

1. Create the necessary DigitalOcean resources
2. Set up the CI/CD pipeline
3. Configure environment variables
4. Deploy the application
5. Set up monitoring and alerting 