## Builder stage
FROM ruby:3.2.2-slim AS builder

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=placeholder rails assets:precompile 2>/dev/null; true

## Production stage
FROM ruby:3.2.2-slim

RUN apt-get update -qq && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system app && adduser --system --ingroup app app

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

RUN chown -R app:app /app
USER app

EXPOSE 3000
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true

CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"]
