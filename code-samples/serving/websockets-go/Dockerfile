# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
FROM golang:1.27 AS builder

ARG TARGETOS
ARG TARGETARCH

# Create and change to the app directory.
WORKDIR /app

# Copy local code to the container image.
COPY . ./

# Install dependencies and tidy up the go.mod and go.sum files.
RUN go mod tidy

# Build the server by default, or another main package when requested.
ARG APP_PATH=./cmd/server
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -mod=readonly -v -o app "$APP_PATH"

# Use the official Alpine image for a lean production container.
# https://hub.docker.com/_/alpine
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/app /app

# Run the selected application on container startup.
CMD ["/app"]
