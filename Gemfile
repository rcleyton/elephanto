source "https://rubygems.org"

gem "actionview-encoded_mail_to"
gem "bcrypt", "~> 3.1"
gem "bootsnap", require: false
gem "chartkick"
gem "erb-formatter", "~> 0.7.3"
gem "fsrs", git: "https://github.com/open-spaced-repetition/rb-fsrs"
gem "groupdate"
gem "importmap-rails"
gem "jbuilder"
gem "kaminari"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.2"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "stimulus-rails"
gem "stringio", "3.1.1"
gem "tailwindcss-rails", "~> 4.2"
gem "tailwindcss-ruby", "~> 4.1"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "capistrano-passenger", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano", require: false
  gem "guard"
  gem "guard-minitest"
  gem "letter_opener"
  gem "web-console"
  gem "ed25519", "~> 1.3"
  gem "bcrypt_pbkdf", "~> 1.1"
end

group :test do
  gem "capybara"
  gem "minitest-focus"
  gem "minitest-rails", "~> 8.0.0"
  gem "minitest-reporters"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "simplecov", require: false
end

gem "dotenv-rails", groups: [ :staging, :production ]
