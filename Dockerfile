FROM ruby:3.3.0

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client redis

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 9292

CMD ["rackup", "--host", "0.0.0.0", "--port", "9292"]
