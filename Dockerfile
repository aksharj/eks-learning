FROM ubuntu:18.04

RUN apt-get update && apt-get dist-upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs ruby-dev bundler build-essential zlib1g-dev libpq-dev tzdata git curl postgresql-client-10 imagemagick && rm -rf /var/lib/apt/lists/*

RUN useradd -m deploy

WORKDIR /app

COPY Gemfile* ./
RUN mkdir -p vendor
COPY vendor/cache vendor/cache
RUN bundle install --deployment --local --without test development
COPY . .

RUN SECRET_KEY_BASE=abc RAILS_ENV=production bin/rake assets:precompile

RUN mkdir -p tmp/pids
RUN chown -R deploy tmp log db

USER deploy
ENV RAILS_LOG_TO_STDOUT 1

EXPOSE 3000
CMD bin/rake db:migrate && bundle exec passenger start --address 0.0.0.0 --port 3000 --auto --disable-anonymous-telemetry -e production
