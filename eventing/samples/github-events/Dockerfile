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

WORKDIR /go/src/github.com/knative/docs/
ADD . /go/src/github.com/knative/docs/

RUN CGO_ENABLED=0 go build ./eventing/samples/github-events

FROM gcr.io/distroless/base

COPY --from=builder /go/src/github.com/knative/docs/github-events /sample

ENTRYPOINT ["/sample"]
EXPOSE 8080


# TODO: FIX IN DOCS REPO:
# Dockerfile pathing is relative to the dockerfile itself which causes two issues here:
# this github-events directory's contents gets placed under /go/src/github.com/knative/docs/ which results in an unable to find eventing/samples/github-events error when compiling. This can be fixed by changing the above command to ADD . /go/src/github.com/knative/docs/eventing/samples/github-events
# Because we are only copying the github-events dir we lack the deps for this example (which are in docs/vendor). ISTM we can either add them with go get or add dep to the docker image along with a Gopkg config and then run dep ensure.