# Use the official lightweight Node.js 12 image.
# https://hub.docker.com/_/node
FROM node:20-alpine as builder

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./
COPY index.js ./

# Use ci is faster and more reliable following package-lock.json
RUN npm ci --only=production

FROM node:20-alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID
ARG ENV=production

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

COPY --from=builder index.js ./
COPY --from=builder package*.json ./
COPY --from=builder node_modules ./node_modules

# Set the non-root user as current.
USER $USER

# Run the web service on container startup.
CMD [ "npm", "start" ]
