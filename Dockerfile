# ===== Stage 1: Build (ставимо dev deps) =====
FROM node:20-alpine AS builder
WORKDIR /app

# Ставимо всі залежності (включно з dev)
COPY package*.json ./
RUN npm ci

# Копіюємо тільки те, що потрібно для білду
COPY tsconfig*.json ./
COPY nest-cli.json ./
COPY src ./src

# Збираємо
RUN npm run build

# ===== Stage 2: Runtime (тільки prod deps) =====
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Ставимо лише прод-залежності, без скриптів встановлення (швидше/безпечніше)
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

# Беремо зібраний код
COPY --from=builder /app/dist ./dist

# Без root
RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000
CMD ["node", "dist/main.js"]
