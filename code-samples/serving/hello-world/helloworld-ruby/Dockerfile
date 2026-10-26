# Use the official lightweight Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:4.0-slim-trixie

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
ENV APP_ENV=production
RUN gem install bundler -v 4.0.23 --no-document && bundle install

# Copy local code to the container image.
COPY . ./

# Run the web service on container startup.
CMD ["bundle", "exec", "ruby", "./app.rb"]
