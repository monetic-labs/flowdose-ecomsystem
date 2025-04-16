FROM node:18-alpine

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production

# Install pnpm
RUN npm install -g pnpm

# Copy package.json and install dependencies
COPY package.json ./
RUN pnpm install

# Copy the rest of the application
COPY . .

# Create the medusa server directory and copy the config
RUN mkdir -p .medusa/server && cp medusa-config.js .medusa/server/

# Expose the application port
EXPOSE 9000

# Start the application (development mode for now)
CMD ["pnpm", "dev"] 