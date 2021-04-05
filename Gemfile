source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3'
gem 'mysql2', '~> 0.5.3'
gem 'mysql2-aurora'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem "hiredis", "~> 0.6.3"
gem 'redis', '~> 4.0', :require => ["redis", "redis/connection/hiredis"]
gem 'redis-namespace', '~> 1.6'
# Use Active Model has_secure_password
# gem 'bcrypt'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# background job
gem 'sidekiq', '~> 5.2.7'
gem 'sidekiq-cron', '~> 1.1.0'
gem 'rufus-scheduler', '~> 3.6.0'

# Authentication & Authorization
# devise gem : 회원관리를 위한 gem 입니다.
# https://github.com/plataformatec/devise
gem 'devise', '~> 4.7', '>= 4.7.3'
gem 'devise-async'
# devise gem 에서 사용되는 메시지들의 다국어 처리를 위한 gem 입니다.
# https://github.com/tigrish/devise-i18n
gem 'devise-i18n', '~> 1.9', '>= 1.9.3'

# Soft Delete (삭제 시 완전삭제가 아닌 삭제처리된 것 처럼 진행하는 기능) 용 gem 입니다.
# https://github.com/rubysherpas/paranoia
gem 'paranoia', '~> 2.4', '>= 2.4.3'
# role
gem 'rolify', '~> 5.3'

# InternalizationAA
# rails 내부에서 사용되는 각종 메시지 및 오류 메시지에 대한 다국어 처리를 위한 gem 입니다.
# https://github.com/svenfuchs/rails-i18n
gem 'rails-i18n', '~> 6.0'

gem 'kaminari', '~> 1.1.1'
# Pagination 표시 Bar 를 bootstrap 형태로 보기 좋게 나오도록 사용하는 gem 입니다.
# https://github.com/matenia/bootstrap-kaminari-views
gem 'bootstrap-kaminari-views'

# OAuth Provider
# https://github.com/doorkeeper-gem/doorkeeper
# gem 'doorkeeper'
# gem 'doorkeeper-i18n'
# gem 'doorkeeper-jwt'
gem 'jwt', '~> 2.2', '>= 2.2.1'

gem 'rack-attack', '~> 5.0'
gem 'rack-cors', require: 'rack/cors'
gem 'swagger-docs', '~> 0.2.9'

gem 'goldiloader', '~> 3.1', '>= 3.1.1'
gem 'oj', '~> 3.9', '>= 3.9.2'

# 접근권한을 policy 형태로 관리할 수 있는 gem 입니다.
# https://github.com/varvet/pundit
gem 'pundit', '~> 2.1'

# Decorator Pattern 적용을 위한 gem 입니다.
# https://github.com/drapergem/draper
gem 'draper', '~> 3.1.0'

# Infinite state machine 구현을 위한 gem 입니다.
# https://github.com/aasm/aasm
gem 'aasm', '~> 5.0', '>= 5.0.6'

gem 'aws-sdk', '~> 3'

# tracking
gem 'paper_trail', '~> 11.1'

gem 'active_record_union', '~> 1.3'
gem 'user_agent_parser', '~> 2.5', '>= 2.5.2'

# http request
gem 'faraday', '~> 0.14.0'

# # 테이블 내의 컬럼명이 rails 의 기본 method 명과 중복인 경우 에러가 발생함. safe_attributes 사용하면 해결됨
# gem 'safe_attributes', '~> 1.0', '>= 1.0.10'

# 파라미터 검증 및 타입 강제
# https://github.com/nicolasblanco/rails_param
gem 'rails_param', '~> 0.11.0'

# fileupload
gem 'carrierwave'

gem "nested_form"

# for text search
gem 'search_cop'

gem 'ancestry', '~> 3.1.0'
gem 'acts-as-taggable-on', '~> 7.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'awesome_print'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate', '~> 3.1', '>= 3.1.1'

  gem 'rubocop', require: false
  gem 'letter_opener', '~> 1.7'
end

group :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'faker'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
