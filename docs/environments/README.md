# Environment Management

This document provides an overview of the different environments used in the Flowdose Ecomsystem project and how they're managed.

## Environment Types

The project uses three main environments:

1. **Local Development**: Used by developers for day-to-day development work
2. **Staging**: Used for testing features before they go to production
3. **Production**: The live environment used by customers

## Environment Configuration

Each environment is configured with its own set of environment variables and resources:

| Environment | Config File     | Database        | Services                   |
|-------------|----------------|-----------------|----------------------------|
| Local       | `.env`         | Local PostgreSQL | Local Redis, MeiliSearch   |
| Staging     | `.env.staging` | DO Managed DB   | DO App Platform Services   |
| Production  | `.env.production` | DO Managed DB | DO App Platform Services  |

## Environment Variable Management

Environment variables are managed differently for each environment:

- **Local**: Environment variables are stored in `.env` files in each service directory
- **Staging/Production**: Environment variables are stored in DO App Platform and sourced from `.env.staging` or `.env.production`

See [Environment Switching](./switching.md) for details on how to switch between environments.

## Environment Isolation

To ensure proper isolation between environments:

1. Each environment has its own database
2. Each environment has its own set of services
3. Environment-specific configurations are stored separately

## Environment Access

Access to environments is controlled as follows:

| Environment | Access Control                                          |
|-------------|--------------------------------------------------------|
| Local       | None (accessible to all developers)                     |
| Staging     | Password-protected, accessible to team and stakeholders |
| Production  | Strict access controls, limited to production team      |

## Environment Switching

See [Environment Switching](./switching.md) for details on how to switch between environments during development. 