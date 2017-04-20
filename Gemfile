source 'https://rubygems.org'

# Padrino supports Ruby version 1.9 and later
# ruby '2.2.3'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'bcrypt'
gem 'activerecord', '>= 3.1', :require => 'active_record'
gem 'pg'

# Test requirements
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.13.1'

gem 'padrino-flash'

gem 'will_paginate', '~> 3.1.1'

gem 'dotenv'

gem 'mail', '2.6.3'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core support gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.13.1'
# end

group :test, :development do
  gem 'shoulda-matchers', require: false
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'poltergeist'
  gem 'mailcatcher'
  gem 'rack_session_access'
  gem 'puffing-billy'
end

group :production do
  gem 'rails_12factor'
end
