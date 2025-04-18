# Flowdose Documentation

This directory contains comprehensive documentation for the Flowdose e-commerce system. This README serves as a guide to navigate the documentation structure.

## Documentation Structure

The documentation is organized into the following main sections:

### [Setup](./setup/)

Documentation for setting up the project in different environments:

- [Local Development](./setup/local-development.md) - **Primary guide** for setting up the local development environment

### [Deployment](./deployment/)

Documentation for deploying the application to different environments:

- [Deployment Guide](./deployment/deployment-guide.md) - Overview of the deployment process
- [Docker Deployment](./deployment/docker.md) - Docker-specific deployment information
- [DigitalOcean Deployment](./deployment/digitalocean.md) - DigitalOcean-specific deployment information
- [GitHub Secrets](./deployment/github-secrets.md) - Setting up GitHub secrets for CI/CD

### [Architecture](./architecture/)

Documentation describing the system architecture:

- [Project Structure](./architecture/project-structure.md) - Overview of the codebase organization

### [Environments](./environments/)

Documentation for environment-specific configurations:

- [Environment Switching](./environments/switching.md) - How to switch between environments
- [Local Environment](./environments/local.md) - **(Deprecated, see Setup/Local Development)**

## Documentation Standards

To maintain consistency across our documentation:

1. **Path References**:
   - Script paths should be referenced as `./scripts/local-dev/` or `./scripts/deployment/`
   - Docker Compose files should be referenced as `./docker/compose/`

2. **Port References**:
   - Storefront: http://localhost:3002
   - Backend API: http://localhost:9000
   - Admin Dashboard: http://localhost:9000/app
   - MeiliSearch: http://localhost:7701
   - MinIO: http://localhost:9000 (API) and http://localhost:9003 (Console)

3. **Environment Files**:
   - Backend: `.env.local`, `.env.staging`, `.env.production`
   - Storefront: `.env.local`, `.env.staging`, `.env.production`

## Contributing to Documentation

When updating documentation:

1. Ensure all path references are consistent with the current project structure
2. Update any outdated information about ports, URLs, or file paths
3. Maintain the separation between setup, deployment, and architecture docs
4. Keep the documentation style consistent

## Future Documentation

As the project evolves, we plan to add:

- API documentation
- Component library documentation
- Testing strategies
- Performance optimization guides 