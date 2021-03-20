web: RAILS_ENV=production PORT=3000 bundle exec puma -C config/puma.rb
worker: RAILS_ENV=production bundle exec sidekiq -q mailer -q mailers -q default -c 3
