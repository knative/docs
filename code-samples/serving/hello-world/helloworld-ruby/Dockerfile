# Use the official lightweight Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:2.6-slim

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install bundler && bundle install

# Copy local code to the container image.
COPY . ./

USER appuser

# Run the web service on container startup.
CMD ["ruby", "./app.rb"]
