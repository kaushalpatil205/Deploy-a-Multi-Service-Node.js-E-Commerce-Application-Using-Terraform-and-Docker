FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy application source code
COPY . .

# Expose cart service port
EXPOSE 3003

# Start the service
CMD ["node", "server.js"]
