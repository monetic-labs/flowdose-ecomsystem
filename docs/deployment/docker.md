# Docker Setup

This document provides instructions for setting up Docker for local development and deployment of the Flowdose Ecomsystem.

## Docker Architecture

The Docker setup consists of the following containers:

1. **Backend Service (Medusa.js)**
2. **Storefront Service (Next.js)**
3. **PostgreSQL Database**
4. **Redis**
5. **MeiliSearch**
6. **MinIO** (S3-compatible object storage)

## Prerequisites

- Docker installed on your machine
- Docker Compose installed on your machine
- Git repository cloned locally

## Docker Setup Files

### Create Dockerfiles

#### Backend Dockerfile

Create a file `backend/Dockerfile`:

```dockerfile
FROM oven/bun:1.1.10

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json bunfig.toml ./
RUN bun install

# Copy the rest of the application
COPY . .

# Install global dependencies
RUN bun add medusajs-launch-utils@latest -g

# Build the application
RUN bun run build

# Create the medusa server directory and copy the config
RUN mkdir -p .medusa/server && cp medusa-config.js .medusa/server/

# Expose the application port
EXPOSE 9000

# Start the application
CMD ["bun", "start"]
```

#### Storefront Dockerfile

Create a file `storefront/Dockerfile`:

```dockerfile
FROM oven/bun:1.1.10

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json bunfig.toml ./
RUN bun install

# Copy the rest of the application
COPY . .

# Build the application
RUN bun run build

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["bun", "run", "start"]
```

### Create Docker Compose File

Create a file `docker-compose.yml` in the project root:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: medusa
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  meilisearch:
    image: getmeili/meilisearch:v1.5
    restart: always
    environment:
      MEILI_MASTER_KEY: masterKey
    ports:
      - "7700:7700"
    volumes:
      - meilisearch_data:/meili_data

  minio:
    image: minio/minio
    restart: always
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    restart: always
    depends_on:
      - postgres
      - redis
      - meilisearch
      - minio
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/medusa
      REDIS_URL: redis://redis:6379
      MEILISEARCH_HOST: http://meilisearch:7700
      MEILISEARCH_ADMIN_KEY: masterKey
      MINIO_ENDPOINT: minio
      MINIO_PORT: 9000
      MINIO_ACCESS_KEY: minioadmin
      MINIO_SECRET_KEY: minioadmin
      MINIO_BUCKET: medusa-bucket
      NODE_ENV: development
    ports:
      - "9000:9000"
    volumes:
      - ./backend:/app
      - /app/node_modules
      - /app/.medusa

  storefront:
    build:
      context: ./storefront
      dockerfile: Dockerfile
    restart: always
    depends_on:
      - backend
    environment:
      NEXT_PUBLIC_MEDUSA_BACKEND_URL: http://localhost:9000
      NEXT_PUBLIC_MEILISEARCH_HOST: http://localhost:7700
      NEXT_PUBLIC_MEILISEARCH_API_KEY: masterKey
    ports:
      - "3000:3000"
    volumes:
      - ./storefront:/app
      - /app/node_modules
      - /app/.next

volumes:
  postgres_data:
  redis_data:
  meilisearch_data:
  minio_data:
```

## Development Environment

For local development, you can use a simplified Docker Compose setup that just runs the dependencies while you run the services locally:

Create a file `docker-compose.dev.yml` in the project root:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: medusa
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  meilisearch:
    image: getmeili/meilisearch:v1.5
    restart: always
    environment:
      MEILI_MASTER_KEY: masterKey
    ports:
      - "7700:7700"
    volumes:
      - meilisearch_data:/meili_data

  minio:
    image: minio/minio
    restart: always
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"

volumes:
  postgres_data:
  redis_data:
  meilisearch_data:
  minio_data:
```

## Usage

### Development Environment

To start the development environment (dependencies only):

```bash
docker-compose -f docker-compose.dev.yml up -d
```

Then run your services locally:

```bash
# Backend
cd backend
bun run dev

# Storefront
cd storefront
bun run dev
```

### Full Docker Environment

To start the full Docker environment:

```bash
docker-compose up -d
```

This will start all services, including the backend and storefront.

### Building Images

To build the Docker images:

```bash
docker-compose build
```

### Stopping the Environment

To stop and remove the containers:

```bash
docker-compose down
```

To stop and remove the containers and volumes:

```bash
docker-compose down -v
```

## Production Deployment with Docker

For production deployment, create a production-specific Docker Compose file:

Create a file `docker-compose.prod.yml` in the project root:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    restart: always
    environment:
      NODE_ENV: production
    ports:
      - "9000:9000"
    env_file:
      - ./backend/.env.production

  storefront:
    build:
      context: ./storefront
      dockerfile: Dockerfile
    restart: always
    depends_on:
      - backend
    ports:
      - "3000:3000"
    env_file:
      - ./storefront/.env.production
```

To deploy to production:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Multi-Environment Setup

To support multiple environments (local, staging, production), you can create environment-specific Docker Compose files:

- `docker-compose.yml` - Base configuration
- `docker-compose.override.yml` - Local overrides (created automatically)
- `docker-compose.staging.yml` - Staging configuration
- `docker-compose.prod.yml` - Production configuration

Then use the appropriate file for each environment:

```bash
# Staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Docker Scripts

Add these scripts to your project's `package.json` to simplify Docker operations:

```json
"scripts": {
  "docker:dev": "docker-compose -f docker-compose.dev.yml up -d",
  "docker:build": "docker-compose build",
  "docker:up": "docker-compose up -d",
  "docker:down": "docker-compose down",
  "docker:staging": "docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d",
  "docker:prod": "docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
}
```

## Docker Best Practices

1. **Use multi-stage builds** to keep image sizes small
2. **Don't run containers as root** for security
3. **Use environment variables** for configuration
4. **Pin specific versions** of base images
5. **Use .dockerignore** to exclude unnecessary files
6. **Regularly update base images** for security patches
7. **Scan images for vulnerabilities** before deployment

## Troubleshooting

### Common Issues

1. **Container fails to start**: Check the logs with `docker-compose logs <service_name>`
2. **Database connection issues**: Ensure the database is running and the connection URL is correct
3. **Permission issues**: Check file permissions in mounted volumes
4. **Port conflicts**: Ensure no other services are using the same ports 