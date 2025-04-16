FROM oven/bun:1.1.10

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json bunfig.toml ./
RUN bun install

# Copy the rest of the application
COPY . .

# Build the application
RUN bun run build

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["bun", "run", "start"] 