# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang as builder

ARG TARGETOS
ARG TARGETARCH

# Copy local code to the container image.
WORKDIR /go/src/github.com/knative/docs/hellosecrets
COPY . .

# Build the output command inside the container.
RUN CGO_ENABLED=0 GOOS=linux GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o hellosecrets

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER && \
    apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /go/src/github.com/knative/docs/hellosecrets/hellosecrets ./hellosecrets

USER $USER

# Run the web service on container startup.
CMD ["./hellosecrets"]
