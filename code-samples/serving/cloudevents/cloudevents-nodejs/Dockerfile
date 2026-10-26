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

FROM node:24.22.1-alpine

WORKDIR /app

# Install only the locked runtime dependencies; keep development tools out of the image.
COPY package*.json ./
RUN npm ci --omit=dev --cache=/tmp/npm-cache && rm -rf /tmp/npm-cache

ENV PORT=8080 NODE_ENV=production
EXPOSE 8080

COPY --chown=node:node . ./
USER node

# Run Node directly so the application receives container lifecycle signals.
CMD ["node", "index.js"]
