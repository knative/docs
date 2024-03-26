# Copyright 2020 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

# Doc port listening port
ENV PORT=8080
ENV NODE_ENV=$ENV

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

COPY --from=builder index.js ./
COPY --from=builder package*.json ./
COPY --from=builder node_modules ./node_modules

EXPOSE $PORT

USER $USER

# Run the web service on container startup.
CMD npm run $NODE_ENV
