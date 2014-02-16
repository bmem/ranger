source 'https://rubygems.org'

gem 'rails', '~> 3.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# needed for conversion
gem 'mysql2'
gem 'activerecord-mysql-adapter'

gem 'json'

# run "rails generate audited:upgrade" when upgrading
gem 'audited-activerecord' ,'~> 3.0'

gem 'will_paginate', '~> 3.0'

# slug URL fragments for some models
gem 'friendly_id'

# mostly for String.to_ascii to help tokenization
gem 'stringex'

# record text search without needing to configure a separate search engine
gem 'acts_as_indexed'

# autocomplete search results
gem 'twitter-typeahead-rails'

# TODO this is just CSV in 1.9 and it complains loudly if you try to use
# FasterCSV.  Figure out how to dispatch appropriately or whether to ditch
# 1.8 support entirely.
gem 'fastercsv'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2'
  gem 'coffee-rails', '~> 3.2'

  gem 'handlebars_assets'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'meta_request'
end

gem 'jquery-rails', '< 3.0' # TODO jquery-ui-rails, jquery-ui-sass-rails

gem 'haml-rails'

gem 'formtastic'

gem 'acts-as-taggable-on'

gem 'strong_parameters' # TODO this comes by default in Rails 4

# Patched to fix various stack overflow and sqlite compatibility errors
#gem "rails_sql_views", :git => "git://github.com/flwyd/rails_sql_views"

gem 'pundit'
gem 'devise'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'
