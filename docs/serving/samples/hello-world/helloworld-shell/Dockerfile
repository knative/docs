# Use the offical Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.12 as builder

# Copy local code to the container image.
WORKDIR /go/src/github.com/knative/docs/helloworld-shell
COPY invoke.go .

# Build the command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN CGO_ENABLED=0 GOOS=linux go build -v -o invoke

# The official Alpine base image
# https://hub.docker.com/_/alpine
# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3.10

# Copy Go binary
COPY --from=builder /go/src/github.com/knative/docs/helloworld-shell/invoke /invoke
COPY script.sh .

# Run the web service on container startup.
CMD ["/invoke"]
