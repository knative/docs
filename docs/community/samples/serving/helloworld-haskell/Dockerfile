# Use the official Haskell image to create a build artifact.
# https://hub.docker.com/_/haskell/
FROM haskell:8.2.2 as builder

# Copy local code to the container image.
WORKDIR /app
COPY . .

# Build and test our code, then build the “helloworld-haskell-exe” executable.
RUN stack setup
RUN stack build --copy-bins

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM fpco/haskell-scratch:integer-gmp

# Copy the "helloworld-haskell-exe" executable from the builder stage to the production image.
WORKDIR /root/
COPY --from=builder /root/.local/bin/helloworld-haskell-exe .

# Run the web service on container startup.
CMD ["./helloworld-haskell-exe"]
