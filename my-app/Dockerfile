# Stage 1: Builder
FROM node:18-alpine AS builder

# Installa pnpm
# RUN npm install -g pnpm

# Setta la working directory
WORKDIR /app

# Copia i file necessari per il build
COPY package-lock.json ./
#COPY pnpm-workspace.yaml ./
COPY package.json ./
#COPY package.json ./apps/web/
#COPY apps/web/ ./apps/web/
COPY app/ ./app/

# Installa le dipendenze e builda il progetto
# RUN npm install --frozen-lockfile
RUN npm ci
RUN npm run build

# Stage 2: Runner
FROM node:18-alpine AS runner

# Setta la working directory
WORKDIR /app

# Copia solo i file necessari per il runtime
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/app ./app
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public

# Esponi la porta dell'applicazione
EXPOSE 3000

# Comando di avvio
# CMD ["node_modules/.bin/next", "start"]
CMD ["npm", "start"]
