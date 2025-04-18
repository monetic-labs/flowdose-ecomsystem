# Deployment Guide

This guide outlines the process for deploying the Flowdose e-commerce system to staging and production environments.

## Deployment Environments

The application supports three deployment environments:
- **local**: For local development
- **staging**: For testing before production
- **production**: For live, customer-facing deployments

## Deployment Process

Our deployment process uses the deployment scripts in the `scripts/deployment` directory:

### 1. Preparing for Deployment

Before deploying, make sure:
- All changes are committed to the repository
- Tests pass locally
- Environment variables are configured for the target environment

### 2. Deploying to Staging

```bash
./scripts/deployment/deploy.sh staging
```

This will:
- Build the application with staging configurations
- Deploy the backend and storefront to the staging environment
- Configure the necessary infrastructure

### 3. Deploying to Production

```bash
./scripts/deployment/deploy.sh production
```

The production deployment process:
- Builds optimized production bundles
- Deploys to production servers
- Sets up proper scaling and infrastructure

## Infrastructure Configuration

The deployment scripts configure the necessary infrastructure:

- **Database**: PostgreSQL database is set up and migrations are applied
- **Search**: MeiliSearch index is created and configured
- **Storage**: MinIO/S3 buckets are configured for media storage
- **Cache**: Redis instance is set up for caching

## Continuous Integration/Continuous Deployment

Our CI/CD pipeline automates the testing and deployment process:

1. **Pull Request**: Tests are run automatically
2. **Merge to Main**: Triggers automatic deployment to staging
3. **Production Release**: Manual trigger required for production deployment

## Monitoring and Logs

After deployment, monitor the application using:

- **Application Logs**: Available in the deployment environment
- **Database Monitoring**: Monitor database performance
- **Error Tracking**: Track and alert on application errors

## Rollback Procedure

If issues are encountered after deployment:

```bash
./scripts/deployment/deploy.sh rollback
```

This will revert to the previous stable deployment. 