# Use the official Node.js image as the base image
FROM node:20-slim AS base

# Enable corepack for managing pnpm
RUN corepack enable

# Set the pnpm store directory
VOLUME [ "/pnpm-store", "/app/node_modules" ]
RUN pnpm config --global set store-dir /pnpm-store

# Set the working directory
WORKDIR /app

# Copy necessary files
COPY package.json .
COPY apps/web/package.json ./apps/web/package.json
COPY pnpm-lock.yaml .
COPY turbo.json .
COPY pnpm-workspace.yaml .
COPY packages/eslint-config ./packages/eslint-config
COPY packages/typescript-config ./packages/typescript-config
COPY packages/ui ./packages/ui
COPY apps/web/ ./apps/web/

# Install dependencies and build the project
RUN pnpm install --frozen-lockfile
RUN pnpm build
RUN pnpm prune --prod

# Verify the installation
RUN ls -la
RUN cd apps/web && ls -la

# Use the base image for the final stage
FROM base

# Copy the necessary files from the base stage
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/apps/web/.next ./.next
COPY --from=base /app/apps/web/package.json ./package.json
COPY --from=base /app/packages/eslint-config ./packages/eslint-config
COPY --from=base /app/packages/typescript-config ./packages/typescript-config
COPY --from=base /app/packages/ui ./packages/ui

# Expose the port
EXPOSE 3000

# Start the application
CMD [ "pnpm", "start" ]
