# Project Structure

The Flowdose e-commerce system is organized as a monorepo containing both the backend and frontend applications. This document outlines the structure of the codebase and explains the purpose of each major directory.

## Root Directory

```
flowdose-ecomsystem/
├── backend/             # Medusa backend application
├── storefront/          # Next.js frontend application
├── docker/              # Docker-related configuration
│   └── compose/         # Docker Compose files
├── scripts/             # Utility scripts
│   ├── local-dev/       # Local development scripts
│   ├── deployment/      # Deployment scripts
│   └── utils/           # Utility scripts
├── docs/                # Documentation
│   ├── setup/           # Setup guides
│   ├── deployment/      # Deployment guides
│   └── architecture/    # Architecture documentation
├── terraform/           # Infrastructure as Code
└── deploy/              # Deployment configurations
```

## Backend (Medusa)

The backend directory contains the Medusa application that serves as the e-commerce backend:

```
backend/
├── .medusa/             # Medusa cache
├── src/                 # Source code
│   ├── api/             # API endpoints
│   ├── models/          # Data models
│   ├── services/        # Business logic services
│   └── subscribers/     # Event handlers
├── .env.local           # Local environment variables
├── .env.staging         # Staging environment variables
├── .env.production      # Production environment variables
├── medusa-config.js     # Medusa configuration
├── Dockerfile           # Docker configuration for production
└── package.json         # Node.js dependencies
```

## Storefront (Next.js)

The storefront directory contains the Next.js application that serves as the customer-facing website:

```
storefront/
├── .next/               # Next.js build artifacts
├── src/                 # Source code
│   ├── app/             # App router pages
│   ├── components/      # React components
│   ├── lib/             # Utility functions
│   └── styles/          # CSS styles
├── public/              # Static assets
├── .env.local           # Local environment variables
├── .env.staging         # Staging environment variables
├── .env.production      # Production environment variables
├── next.config.js       # Next.js configuration
├── Dockerfile           # Docker configuration for production
└── package.json         # Node.js dependencies
```

## Docker

Docker configuration files for local development and deployment:

```
docker/
└── compose/
    ├── docker-compose.infra.yml     # Infrastructure services
    ├── docker-compose.local.yml     # Local development setup
    └── docker-compose.backend.yml   # Backend service configuration
```

## Scripts

Utility scripts for development, deployment, and operations:

```
scripts/
├── local-dev/
│   ├── start-flowdose.sh            # Script to start the local environment
│   └── local-dev.sh                 # Development utilities
├── deployment/
│   ├── deploy.sh                    # Deployment script
│   └── build.sh                     # Build script
└── utils/
    └── ... (utility scripts)
```

## Terraform

Infrastructure as Code for provisioning cloud resources:

```
terraform/
├── modules/              # Reusable Terraform modules
├── environments/         # Environment-specific configurations
│   ├── staging/          # Staging environment
│   └── production/       # Production environment
└── variables.tf          # Common variables
```

## Configuration Requirements

### Environment Variables

Each application requires specific environment variables to function properly:

1. **Backend (.env files)**:
   - Database connection details
   - Redis connection details
   - Meilisearch configuration
   - S3/MinIO configuration
   - JWT secrets

2. **Storefront (.env files)**:
   - Backend URL
   - Publishable API key
   - Search configuration
   - Base URL

## Development Workflow

1. Local development is done using the `start-flowdose.sh` script
2. Code changes are committed to the repository
3. CI/CD pipeline runs tests and deploys to staging
4. After verification, changes are deployed to production 