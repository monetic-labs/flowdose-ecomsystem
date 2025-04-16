FROM node:22-alpine

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production

# Install pnpm
RUN npm install -g pnpm

# Copy package.json and install dependencies
COPY package.json .npmrc* ./
RUN pnpm install

# Copy the rest of the application
COPY . .

# Build the application
RUN pnpm build

# Create required directories
RUN mkdir -p .medusa/server
RUN cp -f medusa-config.js .medusa/server/

# Expose port
EXPOSE 9000

# Start the Medusa server
CMD ["pnpm", "start"] 