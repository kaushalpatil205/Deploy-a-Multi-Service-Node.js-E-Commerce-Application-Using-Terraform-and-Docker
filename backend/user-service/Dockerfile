FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy application source code
COPY . .

# Expose user service port
EXPOSE 3001

# Start the service
CMD ["node", "server.js"]
