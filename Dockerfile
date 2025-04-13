# Stage 1: Builder
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first for dependency installation
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the TypeScript application
RUN npm run build

# Stage 2: Release
FROM node:18-alpine AS release

# Set working directory
WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

# Set environment to production
ENV NODE_ENV=production

# Install only production dependencies
RUN npm ci --omit=dev

# Command to run the application
CMD ["node", "dist/index.js"]