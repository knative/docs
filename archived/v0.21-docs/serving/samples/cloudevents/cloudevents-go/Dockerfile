# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.13 as builder

# Create and change to the app directory.
WORKDIR /app

# Copy local code to the container image.
COPY . ./

# Ensure Go modules are on and create the go.mod and go.sum files.
# Also builds the binary
ENV GO111MODULE=on
RUN go mod init cloudevents.go \
    && CGO_ENABLED=0 GOOS=linux go build -v -o server

# Allows the container builds to reuse downloaded dependencies.
RUN go mod download

# Use the official Alpine image for a lean production container.
# https://hub.docker.com/_/alpine
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /server

# Run the web service on container startup.
CMD ["/server"]
