Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  sidekiq_user = Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :user)
  sidekiq_password = Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :password)

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(sidekiq_user)) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(sidekiq_password))
  end

  # Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
  mount Sidekiq::Web, at: "/sidekiq"

  get '/health', to: proc { [200, {}, ['']] }


end
