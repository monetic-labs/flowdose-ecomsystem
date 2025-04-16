FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package configuration files first
COPY package.json .npmrc ./

# Install dependencies
RUN pnpm install --no-frozen-lockfile

# Copy the rest of the application
COPY . .

# Set environment variables for build and runtime
ENV NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://137.184.81.212:9000
ENV NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=Webshop

# Build the application
RUN pnpm run build

# Switch to production for runtime
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the server
CMD ["pnpm", "run", "start"] 