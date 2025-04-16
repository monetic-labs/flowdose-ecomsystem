FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Define build-time arguments
ARG NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://admin.flowdose.xyz
ARG NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=Webshop
ARG NEXT_PUBLIC_BASE_URL=https://store.flowdose.xyz

# Copy package configuration files first
COPY package.json .npmrc ./

# Install dependencies
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the application
COPY . .

# Set environment variables specifically for the build step
ENV NEXT_PUBLIC_MEDUSA_BACKEND_URL=$NEXT_PUBLIC_MEDUSA_BACKEND_URL
ENV NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_BASE_URL=$NEXT_PUBLIC_BASE_URL

# Build the application using next build directly
RUN pnpm run build:next

# Unset build-specific ENV vars if needed (optional, as we set NODE_ENV next)
# ENV NEXT_PUBLIC_MEDUSA_BACKEND_URL=""
# ENV NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=""
# ENV NEXT_PUBLIC_BASE_URL=""

# Switch to production for runtime
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the server using the standard start script
# This script likely relies on runtime ENV vars set via docker-compose
CMD ["pnpm", "run", "start"] 