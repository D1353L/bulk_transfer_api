# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 8.0.2'

gem 'bootsnap', require: false
gem 'dry-schema', '~> 1.14'
gem 'puma', '~> 6.0'
gem 'rswag', '~> 2.16'
gem 'sqlite3', '~> 2.1'

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'rspec-rails', '~> 8.0'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers', '~> 6.5'
end
