FROM oven/bun:1.1.10

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json bunfig.toml ./
RUN bun install

# Copy the rest of the application
COPY . .

# Build the application
RUN bun run build

# Create the medusa server directory and copy the config
RUN mkdir -p .medusa/server && cp medusa-config.js .medusa/server/

# Expose the application port
EXPOSE 9000

# Start the application
CMD ["bun", "start"] 