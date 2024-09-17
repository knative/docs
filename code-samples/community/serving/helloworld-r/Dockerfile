# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
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
RUN CGO_ENABLED=0 GOOS=linux GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o invoke

# The official R base image
# https://hub.docker.com/_/r-base
# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM r-base:3.6.0

# Copy Go binary
COPY --from=builder /app/invoke /invoke
COPY HelloWorld.R .

# Run the web service on container startup.
CMD ["/invoke"]
