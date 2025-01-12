# Stage 1: Builder
FROM node:18-alpine AS builder

# Installa pnpm
RUN npm install -g pnpm

# Setta la working directory
WORKDIR /app

# Copia i file necessari per il build
COPY pnpm-lock.yaml ./
COPY turbo.json ./
COPY pnpm-workspace.yaml ./
COPY package.json ./
COPY apps/web/package.json ./apps/web/
COPY apps/web/ ./apps/web/

# Installa le dipendenze e builda il progetto
RUN pnpm install --frozen-lockfile
RUN pnpm build

# Stage 2: Runner
FROM node:18-alpine AS runner

# Setta la working directory
WORKDIR /app

# Copia solo i file necessari per il runtime
COPY --from=builder /app/apps/web/.next ./.next
COPY --from=builder /app/apps/web/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# Esponi la porta dell'applicazione
EXPOSE 3000

# Comando di avvio
CMD ["node_modules/.bin/next", "start"]
