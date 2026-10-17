# Stage 1: Build React Application
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
ENV CI=false
ENV DISABLE_ESLINT_PLUGIN=true
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose ports for web traffic (HTTP 80 and React default 3000)
EXPOSE 80
EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
