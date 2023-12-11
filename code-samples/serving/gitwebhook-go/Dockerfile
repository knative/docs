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

FROM golang AS builder

ARG TARGETOS
ARG TARGETARCH

# copy the source
ADD .   /go/src/github.com/knative/docs/code-samples/serving/gitwebhook-go
WORKDIR /go/src/github.com/knative/docs/code-samples/serving/gitwebhook-go

# install dependencies
RUN go get github.com/google/go-github/github
RUN go get golang.org/x/oauth2
RUN go get gopkg.in/go-playground/webhooks.v3
RUN go get gopkg.in/go-playground/webhooks.v3/github

# build the sample
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /go/bin/webhook-sample .

FROM golang:alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

ENV PORT=8080

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

COPY --from=builder /go/bin/webhook-sample ./webhook-sample

EXPOSE $PORT

USER $USER

ENTRYPOINT ["./webhook-sample"]
