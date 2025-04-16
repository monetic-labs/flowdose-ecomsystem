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

# Expose the application port
EXPOSE 3000

# Start the application (development mode for now)
CMD ["pnpm", "dev"] 