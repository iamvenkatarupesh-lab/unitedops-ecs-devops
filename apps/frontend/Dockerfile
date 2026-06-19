FROM --platform=linux/amd64 node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM --platform=linux/amd64 node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG NEXT_PUBLIC_FLIGHT_API_URL=""
ARG NEXT_PUBLIC_BOOKING_API_URL=""
ARG NEXT_PUBLIC_CHECKIN_API_URL=""
ARG NEXT_PUBLIC_NOTIFICATION_API_URL=""
ENV NEXT_PUBLIC_FLIGHT_API_URL=$NEXT_PUBLIC_FLIGHT_API_URL
ENV NEXT_PUBLIC_BOOKING_API_URL=$NEXT_PUBLIC_BOOKING_API_URL
ENV NEXT_PUBLIC_CHECKIN_API_URL=$NEXT_PUBLIC_CHECKIN_API_URL
ENV NEXT_PUBLIC_NOTIFICATION_API_URL=$NEXT_PUBLIC_NOTIFICATION_API_URL
RUN npm run build

FROM --platform=linux/amd64 node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
