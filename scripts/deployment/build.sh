#!/bin/bash
# Flowdose ecosystem build and deployment script

set -e

# Help function
function show_help {
  echo "Usage: ./build.sh [options]"
  echo "Options:"
  echo "  --backend        Build backend only"
  echo "  --storefront     Build storefront only"
  echo "  --deploy         Deploy after building"
  echo "  --env ENV        Environment (staging or production) [default: production]"
  echo "  --token TOKEN    DigitalOcean API token (required for deployment)"
  echo "  --help           Display this help message"
  exit 0
}

# Error handling function
function error_exit {
  echo "ERROR: $1" >&2
  exit 1
}

# Default values
BUILD_BACKEND=false
BUILD_STOREFRONT=false
DEPLOY=false
ENVIRONMENT="production"
DO_TOKEN=""

# No arguments provided, build both by default
if [ $# -eq 0 ]; then
  BUILD_BACKEND=true
  BUILD_STOREFRONT=true
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --backend)
      BUILD_BACKEND=true
      shift
      ;;
    --storefront)
      BUILD_STOREFRONT=true
      shift
      ;;
    --deploy)
      DEPLOY=true
      shift
      ;;
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --token)
      DO_TOKEN="$2"
      shift 2
      ;;
    --help)
      show_help
      ;;
    *)
      error_exit "Unknown option: $1. Use --help for usage information."
      ;;
  esac
done

# Validate environment
if [[ "$ENVIRONMENT" != "production" && "$ENVIRONMENT" != "staging" ]]; then
  error_exit "Environment must be either 'staging' or 'production'"
fi

# Require token if deploying
if [ "$DEPLOY" = true ] && [ -z "$DO_TOKEN" ]; then
  error_exit "DigitalOcean API token is required for deployment. Use --token."
fi

echo "====== Flowdose Build Script ======"
echo "Environment: $ENVIRONMENT"
echo "Build Backend: $BUILD_BACKEND"
echo "Build Storefront: $BUILD_STOREFRONT"
echo "Deploy: $DEPLOY"
echo "=================================="

# Build backend if requested
if [ "$BUILD_BACKEND" = true ]; then
  echo "Building backend..."
  cd backend
  
  # Remove previous build artifacts to ensure clean build
  rm -rf .medusa/admin .medusa/server/public/admin build public/admin
  
  # Install dependencies
  pnpm install
  
  # Build application
  pnpm build
  
  # Run initialization script
  pnpm init
  
  echo "Backend build completed!"
  cd ..
fi

# Build storefront if requested
if [ "$BUILD_STOREFRONT" = true ]; then
  echo "Building storefront..."
  cd storefront
  
  # Install dependencies
  pnpm install
  
  # Build application
  pnpm build
  
  echo "Storefront build completed!"
  cd ..
fi

# Deploy if requested
if [ "$DEPLOY" = true ]; then
  echo "Deploying to $ENVIRONMENT environment..."
  
  # Build backend container
  if [ "$BUILD_BACKEND" = true ]; then
    echo "Building backend container..."
    cd backend
    docker build -t flowdose-backend:$ENVIRONMENT .
    cd ..
  fi
  
  # Build storefront container
  if [ "$BUILD_STOREFRONT" = true ]; then
    echo "Building storefront container..."
    cd storefront
    docker build -t flowdose-storefront:$ENVIRONMENT .
    cd ..
  fi
  
  # Run deployment
  echo "Running deployment script..."
  ./deploy.sh --environment $ENVIRONMENT --token $DO_TOKEN
  
  echo "Deployment completed!"
fi

echo "Build process completed successfully!" 