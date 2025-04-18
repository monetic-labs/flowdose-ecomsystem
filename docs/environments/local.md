# Local Development Environment

> **DEPRECATED**: This documentation has been moved to [Local Development Setup Guide](../setup/local-development.md).
> Please refer to the new guide for the most up-to-date instructions.

This guide explains how to set up and use the local development environment for the Flowdose Ecomsystem.

## Prerequisites

- Node.js (version 18.x, 20.x, or 22.x)
- Bun (version 1.1.10 or later)
- Docker and Docker Compose (for running dependencies)
- Git

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/flowdose-ecomsystem.git
cd flowdose-ecomsystem
```

### 2. Start Dependencies

The quickest way to get started is to use Docker Compose to run the dependencies:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

This will start:
- PostgreSQL database
- Redis
- MeiliSearch
- MinIO (S3-compatible object storage)

### 3. Set Up Backend

```bash
# Navigate to backend directory
cd backend

# Copy environment variables
cp .env.example .env

# Install dependencies
bun install

# Build the application
bun run build

# Start the development server
bun run dev
```

### 4. Set Up Storefront

```bash
# Navigate to storefront directory
cd ../storefront

# Copy environment variables
cp .env.local.template .env.local

# Install dependencies
bun install

# Start the development server
bun run dev
```

## Accessing the Applications

- Backend API: http://localhost:9000
- Admin Dashboard: http://localhost:9000/admin
- Storefront: http://localhost:3000

## Environment Variables

### Backend Environment Variables

The backend service requires these key environment variables in the `.env` file:

```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/medusa
REDIS_URL=redis://localhost:6379
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_ADMIN_KEY=masterKey
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
NEXT_PUBLIC_MEILISEARCH_HOST=http://localhost:7700
NEXT_PUBLIC_MEILISEARCH_API_KEY=masterKey
```

## Development Workflow

### Backend Development

1. Make code changes in the `backend/src` directory
2. The development server will automatically reload

To run database migrations:

```bash
cd backend
bun run dev:migrate
```

To seed the database:

```bash
cd backend
bun run seed
```

### Storefront Development

1. Make code changes in the `storefront/src` directory
2. The development server will automatically reload

To run tests:

```bash
cd storefront
bun run test
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Ensure PostgreSQL is running: `docker-compose -f docker-compose.dev.yml ps`
   - Check the database URL in `.env`
   - Try connecting directly: `psql postgres://postgres:postgres@localhost:5432/medusa`

2. **Missing Dependencies**:
   - Try removing node_modules and reinstalling: `rm -rf node_modules && bun install`

3. **Port Conflicts**:
   - If ports are already in use, modify the port mappings in `docker-compose.dev.yml`

4. **Docker Issues**:
   - Restart the containers: `docker-compose -f docker-compose.dev.yml restart`
   - Check logs: `docker-compose -f docker-compose.dev.yml logs -f`

## Next Steps

After setting up your local environment, you can:

1. Explore the [API documentation](http://localhost:9000/api-docs)
2. Access the admin dashboard at http://localhost:9000/admin
3. Modify the storefront at http://localhost:3000

For more information, see the [Deployment Documentation](../deployment/README.md). 