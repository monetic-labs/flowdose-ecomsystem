#!/bin/bash

# Flowdose Startup Script
# Usage: ./start-flowdose.sh [local|staging|production]

set -e

ENVIRONMENT=${1:-local}  # Default to local if no argument provided

# Get the absolute path of the script
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

echo "🚀 Starting Flowdose in $ENVIRONMENT environment"

# Function to check if Docker is running
check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
  fi
}

# Stop any running containers
stop_containers() {
  echo "🛑 Stopping any running Flowdose containers..."
  docker-compose -f $PROJECT_ROOT/docker/compose/docker-compose.infra.yml down 2>/dev/null || true
}

# Initialize infrastructure
start_infrastructure() {
  echo "🏗️  Starting infrastructure services (PostgreSQL, Redis, MeiliSearch, MinIO)..."
  docker-compose -f $PROJECT_ROOT/docker/compose/docker-compose.infra.yml up -d
}

# Set environment variables based on environment
setup_environment() {
  if [ "$ENVIRONMENT" = "local" ]; then
    echo "🔧 Setting up local environment..."
    export NODE_ENV=development
    cp -f $PROJECT_ROOT/backend/.env.local $PROJECT_ROOT/backend/.env
    cp -f $PROJECT_ROOT/storefront/.env.local $PROJECT_ROOT/storefront/.env
  elif [ "$ENVIRONMENT" = "staging" ]; then
    echo "🔧 Setting up staging environment..."
    export NODE_ENV=staging
    cp -f $PROJECT_ROOT/backend/.env.staging $PROJECT_ROOT/backend/.env
    cp -f $PROJECT_ROOT/storefront/.env.staging $PROJECT_ROOT/storefront/.env
  elif [ "$ENVIRONMENT" = "production" ]; then
    echo "🔧 Setting up production environment..."
    export NODE_ENV=production
    cp -f $PROJECT_ROOT/backend/.env.production $PROJECT_ROOT/backend/.env
    cp -f $PROJECT_ROOT/storefront/.env.production $PROJECT_ROOT/storefront/.env
  else
    echo "❌ Invalid environment: $ENVIRONMENT. Use 'local', 'staging', or 'production'."
    exit 1
  fi
}

# Initialize database
initialize_database() {
  echo "🗄️  Initializing database..."
  cd $PROJECT_ROOT/backend
  
  # Wait for PostgreSQL to be ready
  echo "⏳ Waiting for PostgreSQL to be ready..."
  until docker-compose -f $PROJECT_ROOT/docker/compose/docker-compose.infra.yml exec -T flowdose-postgres pg_isready -U postgres > /dev/null 2>&1; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 2
  done
  
  echo "✅ PostgreSQL is ready"
  
  # Run database migrations
  echo "🔄 Running database migrations..."
  npx dotenv-cli -e .env -- npx medusa db:migrate
  
  # Create admin user if not exists
  echo "👤 Creating admin user..."
  npx dotenv-cli -e .env -- npx medusa user --email admin@flowdose.xyz --password ksrql0epofvwg6qlhpnwdxak2704wu87 || true
  
  cd ..
}

# Start backend
start_backend() {
  echo "🚀 Starting backend..."
  cd $PROJECT_ROOT/backend
  # Start in background
  npx dotenv-cli -e .env -- npx medusa develop &
  BACKEND_PID=$!
  cd $PROJECT_ROOT
}

# Start storefront
start_storefront() {
  echo "🚀 Starting storefront..."
  cd $PROJECT_ROOT/storefront
  # Start in background
  npx dotenv-cli -e .env -- npm run dev &
  FRONTEND_PID=$!
  cd $PROJECT_ROOT
}

# Main execution flow
main() {
  check_docker
  stop_containers
  setup_environment
  start_infrastructure
  initialize_database
  
  if [ "$ENVIRONMENT" = "local" ]; then
    start_backend
    start_storefront
    
    echo "
    ✅ Flowdose is now running in $ENVIRONMENT mode!
    
    📊 Access points:
    - Admin Dashboard: http://localhost:9000/app
      - Login with admin@flowdose.xyz / ksrql0epofvwg6qlhpnwdxak2704wu87
    - Storefront: http://localhost:3002
    - MeiliSearch: http://localhost:7701
    - MinIO Console: http://localhost:9003
    
    💡 Press Ctrl+C to stop all services
    "
    
    # Trap Ctrl+C to kill background processes
    trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
    
    # Wait for background processes
    wait
  else
    echo "
    ✅ Infrastructure for $ENVIRONMENT is ready!
    
    For non-local environments, deploy using your CI/CD pipeline or 
    run deployment scripts manually.
    "
  fi
}

main 