# Multi-stage build for VaakSetu
FROM node:20-alpine AS builder

WORKDIR /app

# Build Client
COPY client/package*.json ./client/
RUN cd client && npm ci
COPY client/ ./client/
RUN cd client && npm run build

# Production Image
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5000

# Install server dependencies
COPY server/package*.json ./server/
RUN cd server && npm ci --only=production

# Copy server code and traineddata
COPY server/ ./server/
# Copy client build to be served statically by Express
COPY --from=builder /app/client/dist ./client/dist

EXPOSE 5000

CMD ["node", "server/server.js"]

