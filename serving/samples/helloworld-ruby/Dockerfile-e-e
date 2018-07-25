FROM ruby:2.5

RUN bundle config --global frozen 1

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV PORT 8080
EXPOSE 8080

CMD ["ruby", "./app.rb"]
