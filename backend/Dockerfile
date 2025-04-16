FROM node:18-alpine

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production

# Install pnpm and ts-node
RUN npm install -g pnpm ts-node

# Copy package.json first
COPY package.json ./

# Install express for our simple server
RUN pnpm add express

# Copy our simple startup script
COPY start.js ./

# Expose the application port
EXPOSE 9000

# Start using our simple server script instead of Medusa
CMD ["node", "start.js"] 