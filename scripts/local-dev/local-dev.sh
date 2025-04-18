#!/bin/bash

# Flowdose local development script
# This script helps manage the local Docker environment for Flowdose

set -e

# Get the absolute path of the script
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

COMPOSE_FILE="docker/compose/docker-compose.local.yml"

# Stop any running containers
stop_containers() {
  echo "🛑 Stopping any running containers..."
  docker-compose -f docker/compose/docker-compose.infra.yml down 2>/dev/null || true
}

# Initialize infrastructure
start_infrastructure() {
  echo "🏗️  Starting infrastructure services..."
  docker-compose -f docker/compose/docker-compose.infra.yml up -d
}

case "$1" in
    start)
        echo "Starting Flowdose local development environment..."
        docker-compose -f $COMPOSE_FILE up -d
        echo "Environment started. Services available at:"
        echo "- Backend: http://localhost:9000"
        echo "- Admin Dashboard: http://localhost:9000/app"
        echo "- Storefront: http://localhost:3002"
        echo "- MeiliSearch: http://localhost:7701"
        echo "- MinIO Console: http://localhost:9003"
        ;;
    stop)
        echo "Stopping Flowdose local development environment..."
        docker-compose -f $COMPOSE_FILE down
        echo "Environment stopped."
        ;;
    restart)
        echo "Restarting Flowdose local development environment..."
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $COMPOSE_FILE up -d
        echo "Environment restarted."
        ;;
    logs)
        echo "Showing logs for Flowdose services..."
        if [ -z "$2" ]; then
            docker-compose -f $COMPOSE_FILE logs -f
        else
            docker-compose -f $COMPOSE_FILE logs -f flowdose-$2
        fi
        ;;
    status)
        echo "Flowdose service status:"
        docker-compose -f $COMPOSE_FILE ps
        ;;
    rebuild)
        echo "Rebuilding Flowdose services..."
        if [ -z "$2" ]; then
            docker-compose -f $COMPOSE_FILE build --no-cache
            docker-compose -f $COMPOSE_FILE up -d
        else
            docker-compose -f $COMPOSE_FILE build --no-cache flowdose-$2
            docker-compose -f $COMPOSE_FILE up -d flowdose-$2
        fi
        echo "Rebuild complete."
        ;;
    shell)
        if [ -z "$2" ]; then
            echo "Please specify a service: backend or storefront"
            exit 1
        fi
        echo "Opening shell for flowdose-$2..."
        docker-compose -f $COMPOSE_FILE exec flowdose-$2 sh
        ;;
    create-admin)
        echo "Creating admin user..."
        docker-compose -f $COMPOSE_FILE exec flowdose-backend sh -c "medusa user --email admin@flowdose.xyz --password ksrql0epofvwg6qlhpnwdxak2704wu87"
        echo "Admin user created with:"
        echo "Email: admin@flowdose.xyz"
        echo "Password: ksrql0epofvwg6qlhpnwdxak2704wu87"
        ;;
    reset-db)
        echo "Resetting database..."
        read -p "Are you sure you want to reset the database? This will delete all data. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose -f $COMPOSE_FILE down
            docker volume rm flowdose_postgres_data
            docker-compose -f $COMPOSE_FILE up -d
            echo "Database has been reset."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|rebuild|shell|create-admin|reset-db}"
        echo
        echo "Commands:"
        echo "  start         Start all services"
        echo "  stop          Stop all services"
        echo "  restart       Restart all services"
        echo "  logs [service] View logs (optional: specific service like 'backend')"
        echo "  status        Show service status"
        echo "  rebuild [service] Rebuild services (optional: specific service)"
        echo "  shell <service> Open shell in service container (backend or storefront)"
        echo "  create-admin  Create admin user"
        echo "  reset-db      Reset database (deletes all data)"
        exit 1
        ;;
esac

exit 0 