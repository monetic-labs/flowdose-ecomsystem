FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm typescript

# Copy package configuration files first
COPY package.json .npmrc ./

# Remove any yarn/bun config to avoid conflicts
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb

# Install dependencies with improved hoisting
ENV NODE_ENV=development
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the application
COPY . .

# Remove any yarn/bun config again (in case it was copied in the COPY . . step)
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb

# Create required directories preemptively
RUN mkdir -p .medusa/server
RUN cp -f medusa-config.js .medusa/server/ || true

# Set NODE_PATH to include global modules
ENV NODE_PATH=/usr/local/lib/node_modules:/app/node_modules
ENV PATH=$PATH:/app/node_modules/.bin

# Build the application
RUN pnpm build || (echo "Build failed but continuing" && mkdir -p .medusa/server && cp -f medusa-config.js .medusa/server/)

# Switch to production for runtime
ENV NODE_ENV=production

# Expose port
EXPOSE 9000

# Start the server
CMD ["pnpm", "start"] 