FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy application source code
COPY . .

# Expose order service port
EXPOSE 3004

# Start the service
CMD ["node", "server.js"]
