#!/bin/bash

# Init script for Flowdose backend
# This script handles initialization of the backend, ensuring:
# 1. Admin UI is properly built
# 2. Admin user is created
# 3. Any necessary symlinks are created

set -e

echo "=== Initializing Flowdose Backend ==="

# Ensure we're in the project root
cd "$(dirname "$0")/../.."
ROOT_DIR=$(pwd)

# Build step - ensure the admin UI is properly built
echo "Building admin UI..."
ADMIN_DIR="$ROOT_DIR/.medusa/admin"
SERVER_DIR="$ROOT_DIR/.medusa/server"
BUILD_DIR="$ROOT_DIR/build"
PUBLIC_ADMIN_DIR="$SERVER_DIR/public/admin"

# If the public/admin directory doesn't exist in the server dir, create it
if [ ! -d "$PUBLIC_ADMIN_DIR" ]; then
    echo "Creating $PUBLIC_ADMIN_DIR directory..."
    mkdir -p "$PUBLIC_ADMIN_DIR"
fi

# Run the build
echo "Running Medusa build..."
medusa build 

# Ensure the admin build is accessible where expected
echo "Setting up admin build symlinks..."
mkdir -p "$ROOT_DIR/public"

# Create symlinks to ensure admin UI is accessible from all expected locations
if [ -d "$ADMIN_DIR" ] && [ ! -L "$ROOT_DIR/public/admin" ]; then
    ln -sf "$ADMIN_DIR" "$ROOT_DIR/public/admin"
    echo "Created symlink from $ADMIN_DIR to $ROOT_DIR/public/admin"
fi

if [ -d "$PUBLIC_ADMIN_DIR" ] && [ ! -L "$ROOT_DIR/public/admin" ]; then
    ln -sf "$PUBLIC_ADMIN_DIR" "$ROOT_DIR/public/admin"
    echo "Created symlink from $PUBLIC_ADMIN_DIR to $ROOT_DIR/public/admin"
fi

if [ -d "$PUBLIC_ADMIN_DIR" ] && [ ! -L "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    ln -sf "$PUBLIC_ADMIN_DIR/index.html" "$BUILD_DIR/index.html"
    echo "Created symlink from $PUBLIC_ADMIN_DIR/index.html to $BUILD_DIR/index.html"
fi

# Create admin user
echo "Checking for existing admin user..."
USER_EXISTS=$(node -e "
const { Client } = require('pg');
const client = new Client({ connectionString: process.env.DATABASE_URL });

(async () => {
  try {
    await client.connect();
    const result = await client.query('SELECT COUNT(*) FROM public.user WHERE email = \'admin@flowdose.xyz\'');
    console.log(result.rows[0].count);
    await client.end();
  } catch (err) {
    console.error('Error checking user:', err.message);
    console.log('0');
    process.exit(1);
  }
})();
")

if [ "$USER_EXISTS" = "0" ]; then
    echo "Creating admin user..."
    # Try up to 3 times to create the user (in case of build path issues)
    for i in {1..3}; do
        if medusa user --email admin@flowdose.xyz --password ksrql0epofvwg6qlhpnwdxak2704wu87; then
            echo "Admin user created successfully!"
            break
        else
            echo "Attempt $i to create admin user failed. Retrying..."
            # Create additional symlinks to try to fix path issues
            mkdir -p "$ROOT_DIR/public/admin"
            cp -rf "$ADMIN_DIR"/* "$ROOT_DIR/public/admin/" 2>/dev/null || true
            cp -rf "$PUBLIC_ADMIN_DIR"/* "$ROOT_DIR/public/admin/" 2>/dev/null || true
            
            # If this is the last attempt and it failed, exit with error
            if [ $i -eq 3 ]; then
                echo "Failed to create admin user after 3 attempts."
                echo "You may need to create the admin user manually after deployment."
                # Don't exit with error as this shouldn't stop deployment
            fi
        fi
    done
else
    echo "Admin user already exists. Skipping user creation."
fi

echo "=== Backend initialization completed ===" 