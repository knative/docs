# ---------- Build Container ----------
# This uses our prebuilt dependencies
# container as a base to speed up builds.
# It is used to build our app.
FROM docker.io/{username}/helloworld-rust-nightly:deps AS build

# Set working directory.
WORKDIR /

# Copy the source code.
COPY ./src ./src

# Create a user account to run the app with, 
# remove files from the shell project,
# build the app, and strip the binary to make
# it smaller.
RUN adduser --disabled-password --gecos "" appuser && \
  rm target/x86_64-unknown-linux-musl/release/deps/helloworld_rust_nightly* && \
  cargo build --release && \
  strip target/x86_64-unknown-linux-musl/release/helloworld-rust-nightly
# --------------------

# ---------- Production Container ----------
# Uses the smallest docker container as a base.
# This container only holds what's strictly
# needed to run our app.
FROM scratch

# Set working directory.
WORKDIR /

# Enable the user account we created in the other
# container.
COPY --from=build /etc/passwd /etc/

# Use the ca-certs from the other container,
# which we need if we want to be able to put
# an https proxy in front of the service.
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy over the app we built in the other container.
COPY --from=build target/x86_64-unknown-linux-musl/release/helloworld-rust-nightly ./

# Copy the rocket config file.
COPY Rocket.toml ./

# Become a regular user.
USER appuser

# Specify the server environment by setting
# this environment variable to one of:
# development, staging, or production
# If unset, it will default to production.
ENV ROCKET_ENV ${ROCKET_ENV:-production}

# Specify the port the server should listen
# on by setting this environment variable.
# We must honour the $PORT environment variable
# if it is set, otherwise we must fall back
# to port 8080.
ENV ROCKET_PORT ${PORT:-8080}

# Expose the server on the world on the 
# specified port.
EXPOSE $ROCKET_PORT

# Run our app.
CMD ["./helloworld-rust-nightly"]
# --------------------
