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

FROM golang:1.15 as builder

# copy the source
ADD .   /go/src/github.com/knative/docs/docs/serving/samples/gitwebhook-go
WORKDIR /go/src/github.com/knative/docs/docs/serving/samples/gitwebhook-go

# Ensure Go modules are on and create the go.mod and go.sum files.
# Also builds the binary
RUN CGO_ENABLED=0 go build -o /go/bin/webhook-sample .

# Use a Docker multi-stage build to create a lean production image.
FROM golang:alpine

EXPOSE 8080
COPY --from=builder /go/bin/webhook-sample /app/webhook-sample

ENTRYPOINT ["/app/webhook-sample"]
