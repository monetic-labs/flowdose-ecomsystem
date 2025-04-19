#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting local build and deployment of Flowdose services...${NC}"

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
  exit 1
fi

# Export environment variables from .env file if it exists
if [ -f .env ]; then
  echo -e "${GREEN}Loading environment variables from .env file...${NC}"
  export $(grep -v '^#' .env | xargs)
fi

# Check if docker-compose.local.yml exists
if [ ! -f docker-compose.local.yml ]; then
  echo -e "${RED}Error: docker-compose.local.yml not found.${NC}"
  exit 1
fi

# Build and start services
echo -e "${GREEN}Building and starting services...${NC}"
docker-compose -f docker-compose.local.yml build
docker-compose -f docker-compose.local.yml up -d

# Show logs
echo -e "${GREEN}Services are starting up. Showing logs...${NC}"
echo -e "${YELLOW}Press Ctrl+C to exit logs (services will continue running)${NC}"
docker-compose -f docker-compose.local.yml logs -f

# The log command above will keep running until user presses Ctrl+C
# When user exits logs, show final message
echo -e "${GREEN}Services are running in the background.${NC}"
echo -e "${GREEN}Access the storefront at: http://localhost:3002${NC}"
echo -e "${GREEN}Access the backend API at: http://localhost:9000${NC}"
echo -e "${YELLOW}To stop all services, run: docker-compose -f docker-compose.local.yml down${NC}" 