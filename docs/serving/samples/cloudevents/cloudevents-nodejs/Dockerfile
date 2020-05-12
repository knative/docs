FROM registry.access.redhat.com/ubi8/nodejs-12

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Use ci is faster and more reliable following package-lock.json
RUN npm ci --only=production

# Doc port listening port
ENV PORT 8080

EXPOSE $PORT

ARG ENV=production

ENV NODE_ENV $ENV

# Run the web service on container startup.
CMD npm run $NODE_ENV

# Copy local code to the container image.
COPY . ./
