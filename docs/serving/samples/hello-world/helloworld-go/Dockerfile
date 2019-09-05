# Use the offical Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.13 as builder

# Copy local code to the container image.
WORKDIR /app
COPY . ./

# Build the command inside the container.
# (You may fetch or manage dependencies here,
# either manually or with a tool like "godep".)
RUN CGO_ENABLED=0 GOOS=linux go build -v -o helloworld

# Use the official Alpine image for a lean production container.
# https://hub.docker.com/_/alpine
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3.10
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/helloworld /helloworld

# Run the web service on container startup.
CMD ["/helloworld"]
