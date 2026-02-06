# UniPlus - Video API
# Node.js application for video streaming

FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache \
    curl \
    ffmpeg

# Set working directory
WORKDIR /app

# Copy package files
COPY src/video-api/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY src/video-api/ ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 \
    && chown -R nodejs:nodejs /app

USER nodejs

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "server.js"]
