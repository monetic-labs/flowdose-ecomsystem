# Flowdose Ecomsystem Documentation

This documentation provides comprehensive information about the architecture, deployment process, and environment management for the Flowdose Ecomsystem project.

## Table of Contents

- [Architecture](./architecture/README.md)
- [Deployment](./deployment/README.md)
  - [DigitalOcean Deployment](./deployment/digitalocean.md)
  - [Docker Setup](./deployment/docker.md)
- [Environments](./environments/README.md)
  - [Local Development](./environments/local.md)
  - [Staging](./environments/staging.md)
  - [Production](./environments/production.md)
- [Environment Switching](./environments/switching.md)

## Project Overview

Flowdose Ecomsystem is a monorepo containing multiple services:

- **Backend**: Medusa.js-based e-commerce backend
- **Storefront**: Next.js-based frontend for the e-commerce system

The project uses Bun as the package manager and runtime for both services.

## Quick Start

See the [Local Development](./environments/local.md) guide to get started with local development.

For deployment instructions, see the [Deployment](./deployment/README.md) section. 