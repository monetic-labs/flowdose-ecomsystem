# Environment Switching Guide

This guide explains how to switch between different environments (local, staging, production) in the Flowdose Ecomsystem project.

## Environment Switching Approach

The project uses a combination of environment variables and configuration files to manage environment switching:

1. **Environment Variables**: Used to configure services for different environments
2. **Configuration Files**: Used to set up environment-specific settings

## Local Development to Staging/Production

### Backend Service

To switch between environments in the backend service:

1. **Using .env files**:

   Copy the appropriate environment file:

   ```bash
   # For staging
   cp backend/.env.staging backend/.env

   # For production
   cp backend/.env.production backend/.env
   ```

2. **Using NODE_ENV**:

   Set the environment variable directly:

   ```bash
   # For staging
   export NODE_ENV=staging

   # For production
   export NODE_ENV=production
   ```

   Then start the service:

   ```bash
   cd backend
   bun start
   ```

3. **Using Environment Flag**:

   Pass the environment as a flag:

   ```bash
   cd backend
   bun start --env=staging
   ```

### Storefront Service

To switch between environments in the storefront service:

1. **Using .env files**:

   Copy the appropriate environment file:

   ```bash
   # For staging
   cp storefront/.env.staging storefront/.env.local

   # For production
   cp storefront/.env.production storefront/.env.local
   ```

2. **Using Bun Scripts**:

   Use the environment-specific scripts:

   ```bash
   # For staging
   cd storefront
   bun run dev:staging

   # For production
   cd storefront
   bun run dev:production
   ```

## Adding Environment-Specific Scripts

Add these scripts to the `package.json` files to simplify environment switching:

### Backend package.json

```json
"scripts": {
  "dev": "medusa develop",
  "dev:staging": "NODE_ENV=staging medusa develop",
  "dev:production": "NODE_ENV=production medusa develop",
  "start": "bun run start:production",
  "start:local": "init-backend && cd .medusa/server && medusa start --verbose",
  "start:staging": "NODE_ENV=staging init-backend && cd .medusa/server && medusa start --verbose",
  "start:production": "NODE_ENV=production init-backend && cd .medusa/server && medusa start --verbose"
}
```

### Storefront package.json

```json
"scripts": {
  "dev": "bun run wait && bun run launcher dev",
  "dev:staging": "NEXT_PUBLIC_ENV=staging bun run wait && bun run launcher dev",
  "dev:production": "NEXT_PUBLIC_ENV=production bun run wait && bun run launcher dev",
  "build": "bun run wait && bun run launcher build",
  "build:staging": "NEXT_PUBLIC_ENV=staging bun run wait && bun run launcher build",
  "build:production": "NEXT_PUBLIC_ENV=production bun run wait && bun run launcher build",
  "start": "bun run launcher start",
  "start:staging": "NEXT_PUBLIC_ENV=staging bun run launcher start",
  "start:production": "NEXT_PUBLIC_ENV=production bun run launcher start"
}
```

## Environment Switching Tool

To simplify environment switching, you can add an environment switching script to the project root:

Create a file called `switch-env.js` at the project root:

```javascript
#!/usr/bin/env bun

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Get the environment from the command line
const env = process.argv[2];

if (!env || !['local', 'staging', 'production'].includes(env)) {
  console.error('Please specify an environment: local, staging, or production');
  process.exit(1);
}

console.log(`Switching to ${env} environment...`);

// Backend environment
try {
  console.log('Switching backend environment...');
  
  // Copy the appropriate .env file
  const backendEnvSource = path.join(__dirname, 'backend', `.env.${env === 'local' ? '' : env}`);
  const backendEnvDest = path.join(__dirname, 'backend', '.env');
  
  if (fs.existsSync(backendEnvSource)) {
    fs.copyFileSync(backendEnvSource, backendEnvDest);
    console.log(`Backend environment switched to ${env}`);
  } else {
    console.warn(`Backend .env.${env} file not found. Skipping.`);
  }
} catch (error) {
  console.error('Error switching backend environment:', error);
}

// Storefront environment
try {
  console.log('Switching storefront environment...');
  
  // Copy the appropriate .env file
  const storefrontEnvSource = path.join(__dirname, 'storefront', `.env.${env === 'local' ? 'local' : env}`);
  const storefrontEnvDest = path.join(__dirname, 'storefront', '.env.local');
  
  if (fs.existsSync(storefrontEnvSource)) {
    fs.copyFileSync(storefrontEnvSource, storefrontEnvDest);
    console.log(`Storefront environment switched to ${env}`);
  } else {
    console.warn(`Storefront .env.${env} file not found. Skipping.`);
  }
} catch (error) {
  console.error('Error switching storefront environment:', error);
}

console.log(`Environment switched to ${env}.`);
```

Make the script executable:

```bash
chmod +x switch-env.js
```

Use the script to switch environments:

```bash
# Switch to staging
./switch-env.js staging

# Switch to production
./switch-env.js production

# Switch back to local
./switch-env.js local
```

## Environment Variable Templates

To help with environment variable management, maintain template files for each environment:

- `backend/.env.template` - Template for backend environment variables
- `storefront/.env.local.template` - Template for storefront environment variables

These templates should include all required variables with sample values (but no sensitive information).

## Environment Debugging

To debug environment-related issues:

1. **Check current environment**:

   ```bash
   # Backend
   cd backend
   grep NODE_ENV .env

   # Storefront
   cd storefront
   grep NEXT_PUBLIC_ENV .env.local
   ```

2. **Print all environment variables**:

   ```bash
   # Backend
   cd backend
   bun run -e "console.log(process.env)"

   # Storefront
   cd storefront
   bun run -e "console.log(process.env)"
   ```

3. **Validate environment configuration**:

   ```bash
   # Use the provided check script
   cd storefront
   bun run check-env-variables
   ``` 