# syntax=docker/dockerfile:1

ARG NODE_VERSION=22.13.1

# --- Build Stage ---
FROM node:${NODE_VERSION}-slim AS builder
WORKDIR /app

# Install build dependencies only (no .env, no .git, no lock files)
COPY --link package.json ./
# If you use package-lock.json, uncomment the next line
# COPY --link package-lock.json ./

# Use npm ci for reproducible builds, cache npm
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy the rest of the application (excluding .env, .git, etc.)
COPY --link . .

# Build the production static files
RUN npm run build:prod

# Remove dev dependencies and keep only production dependencies
RUN rm -rf node_modules && \
    npm ci --production

# --- Production Stage ---
FROM node:${NODE_VERSION}-slim AS final
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --ingroup appgroup appuser

# Copy built assets and production dependencies
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096"

USER appuser

# The built Vue app is static. To serve it, use a static server (e.g. serve)
# Install 'serve' globally
RUN npm install -g serve

EXPOSE 8013

CMD ["serve", "-s", "dist", "-l", "8013"]
