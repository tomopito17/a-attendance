source 'https://rubygems.org'

gem 'rails',        '~> 5.1.6'
gem 'rails-i18n'  #8おまけ日本語化。
gem 'bcrypt'  # 4.5
gem 'faker' # 8.4追加してください。
gem 'bootstrap-sass'  #3.2
gem 'will_paginate' # 8.4.2追加してください。
gem 'bootstrap-will_paginate' #8.4.2行を追加してください。
gem 'puma',         '~> 3.7'
gem 'sass-rails',   '~> 5.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks',   '~> 5'
gem 'jbuilder',     '~> 2.5'
gem 'rounding'#BNo10追加

group :development, :test do
  gem 'sqlite3', '1.3.13' #add_1.3.13番外編2
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do  #add番外編2
  gem 'pg', '0.20.0'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
# Mac環境でもこのままでOKです
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]