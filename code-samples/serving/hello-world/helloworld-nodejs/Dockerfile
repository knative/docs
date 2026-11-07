# Use the official lightweight Node.js 24 LTS image.
# https://hub.docker.com/_/node
FROM node:24-bookworm-slim

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm ci on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm ci --omit=dev

# Copy local code to the container image.
COPY . ./

# Run the web service on container startup.
CMD [ "node", "index.js" ]
