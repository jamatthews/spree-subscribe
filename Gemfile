source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'spree', '~> 3.1.0'
# Provides basic authentication functionality for testing parts of your engine
gem 'spree_auth_devise', '~> 3.1'
gem 'spree_mail_settings', github: 'spree-contrib/spree_mail_settings', branch: '3-1-stable'

group :test do
  gem 'capybara', '~> 2.4'
  gem 'capybara-screenshot', '~> 1.0.11'
  gem 'database_cleaner', '~> 1.3'
  gem 'email_spec'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'launchy'
  gem 'rspec-activemodel-mocks', '~> 1.0.2'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '3.4.0'
  gem 'simplecov'
  gem 'webmock', '1.8.11'
  gem 'poltergeist', '1.6.0'
  gem 'timecop'
  gem 'with_model'
  gem 'mutant-rspec', '~> 0.8.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
end

group :test, :development do
  gem 'rubocop', require: false
  gem 'pry-byebug'
end

gemspec