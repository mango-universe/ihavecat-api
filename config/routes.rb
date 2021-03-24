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

  get 'swagger' => 'swagger#index'

  get '/health', to: proc { [200, {}, ['']] }

  devise_for :users

  def api_version(version, default = false, &routes)
    api_constraint = ApiConstraints.new(version: version, default: default)
    scope(module: "v#{version}", path: "v#{version}", constraints: api_constraint, &routes)
  end

  namespace :api, defaults: {format: :json} do
    api_version(1, true) do

    end
  end



end
