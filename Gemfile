source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.4"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"

# Auth
gem "devise", "~> 5.0"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

# Background jobs
gem "good_job", "~> 4.0"

# Payments
gem "stripe", "~> 13.0"

# SEO
gem "sitemap_generator", "~> 7.0"

# Rate limiting
gem "rack-attack"

# UI components
gem "view_component", "~> 4.6"

# Env vars
gem "dotenv-rails", groups: [ :development, :test ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "minitest", "~> 5.25"
end
