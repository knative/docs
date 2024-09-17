# Copyright 2018 The Knative Authors
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

FROM golang:latest AS builder

ARG TARGETOS
ARG TARGETARCH

# Create and change to the app directory.
WORKDIR /app

# Copy local code to the container image.
COPY . ./

# Install dependencies and tidy up the go.mod and go.sum files.
RUN go mod tidy

# Build the binary.
# -mod=readonly ensures immutable go.mod and go.sum in container builds.
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o webhook-sample

FROM golang:alpine

EXPOSE 8080
COPY --from=builder /app/webhook-sample /webhook-sample

ENTRYPOINT ["/webhook-sample"]
