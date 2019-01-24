# Use the official Rust image.
# https://hub.docker.com/_/rust
FROM rust:1.27.0

# Copy local code to the container image.
WORKDIR /usr/src/app
COPY . .

# Install production dependencies and build a release artifact.
RUN cargo install

# Service must listen to $PORT environment variable.
# This default value facilitates local development.
ENV PORT 8080

# Run the web service on container startup.
CMD ["hellorust"]
