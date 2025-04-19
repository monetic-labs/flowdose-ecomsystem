FROM node:18-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package configuration files first
COPY package.json .npmrc ./

# Copy SSL certificates 
COPY certs/ /app/certs/

# Remove any yarn/bun config to avoid conflicts
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb

# Install dependencies with improved hoisting
ENV NODE_ENV=development
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the application
COPY . .

# Remove any package manager configs again
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb

# Create required directories preemptively
RUN mkdir -p .medusa/server
RUN cp -f medusa-config.js .medusa/server/ || true

# Set NODE_PATH to include global modules
ENV NODE_PATH=/usr/local/lib/node_modules:/app/node_modules
ENV PATH=$PATH:/app/node_modules/.bin
ENV PGSSLROOTCERT=/app/certs/do-ca-certificate.crt

# Build the application - will now fail if build fails
RUN pnpm build

# Ensure the admin build is accessible from all required locations
RUN mkdir -p /app/public /app/build
RUN if [ -d /app/.medusa/admin ]; then ln -sf /app/.medusa/admin /app/public/admin; fi
RUN if [ -d /app/.medusa/server/public/admin ]; then ln -sf /app/.medusa/server/public/admin/index.html /app/build/index.html; fi

# Switch to production for runtime
ENV NODE_ENV=production

# Expose port
EXPOSE 9000

# Start the Medusa server directly
CMD ["sh", "-c", "echo 'Starting Medusa backend...' && pnpm start"] 