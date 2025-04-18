# Local Development Setup Guide

This guide provides comprehensive instructions for setting up and running the Flowdose e-commerce system locally.

## Prerequisites

- Docker and Docker Compose
- Node.js (version 18.x, 20.x, or 22.x)
- pnpm (version 8.15.4 or newer)
- Git

## Setup Steps

### 1. Clone the Repository

```bash
git clone [repository-url]
cd flowdose-ecomsystem
```

### 2. Environment Configuration

Copy the example environment files:

```bash
# Backend environment setup
cp backend/.env.local backend/.env

# Storefront environment setup
cp storefront/.env.local storefront/.env
```

### 3. Start the Development Environment

Use our startup script to initialize the development environment:

```bash
./scripts/local-dev/start-flowdose.sh local
```

This script will:
- Start the necessary infrastructure (PostgreSQL, Redis, MeiliSearch, MinIO)
- Set up the correct environment files
- Initialize the database and create an admin user
- Start both the backend and storefront applications

Alternatively, you can use our local development utility script for more control:

```bash
# Start all services
./scripts/local-dev/local-dev.sh start

# View logs
./scripts/local-dev/local-dev.sh logs

# Check status
./scripts/local-dev/local-dev.sh status

# Stop all services
./scripts/local-dev/local-dev.sh stop
```

## Accessing the Applications

Once the startup is complete, you can access the following services:

- **Admin Dashboard**: http://localhost:9000/app
  - Login with admin@flowdose.xyz / ksrql0epofvwg6qlhpnwdxak2704wu87

- **Storefront**: http://localhost:3002

- **MeiliSearch**: http://localhost:7701

- **MinIO Console**: http://localhost:9003
  - Login with minioadmin / minioadmin

## Environment Variables

### Backend Environment Variables

The backend service requires these key environment variables in the `.env` file:

```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/medusa
REDIS_URL=redis://localhost:6379
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=masterKey
MINIO_ENDPOINT=localhost
MINIO_PORT=9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=medusa-bucket
NODE_ENV=development
```

### Storefront Environment Variables

The storefront service requires these key environment variables in the `.env.local` file:

```
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_0b771ab24ba297040c3a61b117c2eb8732256e4808a9e98d0769930aeb00f13a
NEXT_PUBLIC_BASE_URL=http://localhost:3002
PORT=3002
NEXT_PUBLIC_MEILISEARCH_HOST=http://localhost:7701
NEXT_PUBLIC_MEILISEARCH_API_KEY=masterKey
```

## Port Configuration

The storefront uses port 3002. This is configured in multiple places:

1. In `storefront/next.config.js` as the default port in serverRuntimeConfig
2. In `storefront/package.json` as part of the npm scripts
3. In `storefront/.env.local` as the PORT environment variable
4. In `storefront/.env.local` for NEXT_PUBLIC_BASE_URL value 

## Development Workflow

### Backend Development

1. Make code changes in the `backend/src` directory
2. The development server will automatically reload

To run database migrations:

```bash
cd backend
npx medusa db:migrate
```

### Storefront Development

1. Make code changes in the `storefront/src` directory
2. The development server will automatically reload

## Docker Compose Configuration

Our development environment uses Docker Compose to manage infrastructure services. The configuration is located at:

```
docker/compose/docker-compose.infra.yml
```

This file sets up:
- PostgreSQL database
- Redis
- MeiliSearch
- MinIO (S3-compatible object storage)

## Troubleshooting

### Common Issues

1. **Port conflicts**: If you have services already running on ports 3002, 9000, etc., the application will fail to start. Make sure these ports are available.

2. **Environment variables not being loaded**: If environment variables aren't being recognized, make sure your .env files are properly set up and the startup script is correctly loading them.

3. **Database connection issues**: Make sure your PostgreSQL instance is running correctly. You can check the logs of the Docker container using `docker logs flowdose-ecomsystem-flowdose-postgres-1`.

4. **Docker Issues**:
   - Restart the containers: `docker-compose -f docker/compose/docker-compose.infra.yml restart`
   - Check logs: `docker-compose -f docker/compose/docker-compose.infra.yml logs -f`

5. **Publishable API Key Issues**: If you encounter errors about invalid publishable keys, generate a new key:
   ```bash
   node scripts/utils/create-publishable-key.js
   ```
   Then restart both the backend and storefront services.

### Resetting the Environment

To completely reset your environment:

```bash
# Stop and remove containers
docker-compose -f docker/compose/docker-compose.infra.yml down -v

# Clear cached files
rm -rf backend/.medusa 
rm -rf storefront/.next
```

Then restart the environment using the startup script.

## Switching Environments

For switching between local, staging, and production environments, see our [Environment Switching](../environments/switching.md) documentation. 