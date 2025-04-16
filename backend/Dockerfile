FROM oven/bun:1.1.10

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production

# Copy package.json and install dependencies
COPY package.json bunfig.toml ./
RUN bun install

# Copy the rest of the application
COPY . .

# Create the medusa server directory and copy the config
RUN mkdir -p .medusa/server && cp medusa-config.js .medusa/server/

# Expose the application port
EXPOSE 9000

# Start the application in development mode (skipping build for now)
CMD ["bun", "run", "dev"] 