# Use the official lightweight Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:2.6-slim

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

ENV BUNDLE_FROZEN=true
ENV PORT=8080

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Install production dependencies.
COPY Gemfile Gemfile.lock ./

RUN addgroup --gid $USER_GID $USER && \
    adduser -u $USER_UID --ingroup $USER --disabled-password $USER && \
    gem install bundler && bundle install

# Copy local code to the container image.
COPY app.rb ./

# Set the non-root user as current.
USER $USER

# Run the web service on container startup.
CMD ["ruby", "./app.rb"]
