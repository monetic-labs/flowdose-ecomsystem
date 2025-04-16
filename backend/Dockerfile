FROM node:22-alpine

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production

# Install pnpm
RUN npm install -g pnpm

# Copy package configuration files first
COPY package.json .npmrc ./

# Install minimal dependencies
RUN pnpm add express cors

# Copy our simple server file
COPY start.js ./

# Disable SSL certificate validation (security risk, but fixes connection issues)
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Expose port
EXPOSE 9000

# Start using our simple server
CMD ["node", "start.js"] 