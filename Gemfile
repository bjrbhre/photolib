source 'https://rubygems.org'
ruby '2.1.3'

gem 'rake', '~> 10.4.2'

group :development do
  gem 'pry'
  gem 'rspec'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'

  # Mac OS X
  gem 'rb-fsevent', '~> 0.9.1', require: RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'

  # Unix
  gem 'therubyracer', require: 'v8', platforms: :ruby unless RUBY_PLATFORM.include?('darwin')
  gem 'rb-inotify', '~> 0.9', require: RUBY_PLATFORM.include?('linux') && 'rb-inotify'

  # Windows
  gem 'wdm', '>= 0.1.0', require: RUBY_PLATFORM =~ /mswin|mingw/i && 'wdm'

end
