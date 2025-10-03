FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]