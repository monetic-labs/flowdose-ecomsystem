FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package configuration files first
COPY package.json .npmrc ./

# Remove any yarn/bun config to avoid conflicts
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb bunfig.toml

# Install dependencies
ENV NODE_ENV=development
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the application
COPY . .

# Remove any package manager configs again
RUN rm -f .yarnrc.yml .yarn* yarn* bun.lockb bunfig.toml

# Build the application
RUN pnpm run build

# Switch to production for runtime
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the server
CMD ["pnpm", "run", "start"] 