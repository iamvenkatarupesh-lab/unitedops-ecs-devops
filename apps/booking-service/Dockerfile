FROM --platform=linux/amd64 node:20-alpine AS base
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY tsconfig.json ./
COPY src ./src
RUN npm run build

ENV NODE_ENV=production
EXPOSE 4002
CMD ["npm", "start"]
