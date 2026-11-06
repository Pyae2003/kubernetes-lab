# Stage 1: Build / Dependencies
FROM node:22.13.0-alpine3.21 AS builder

WORKDIR /usr/src/app

# Copy package definition files
COPY package*.json ./

# Install dependencies cleanly (production dependencies or all if needed for build)
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Stage 2: Production Image
FROM node:22.13.0-alpine3.21 AS runner

WORKDIR /usr/src/app

# Set environment to production
ENV NODE_ENV=production

# Copy built artifacts and node_modules from builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/server.js ./server.js 
# (Copy any other necessary directories like src/, controllers/, routes/, etc., if your structure separates them)

# Use a non-root user for security best practices
USER node

# Expose the port your app runs on
EXPOSE 5000

# Start the server
CMD ["node", "server.js"]