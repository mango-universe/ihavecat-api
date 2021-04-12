Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  sidekiq_user = Rails.application.credentials.dig(:sidekiq, :user)
  sidekiq_password = Rails.application.credentials.dig(:sidekiq, :password)

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(sidekiq_user)) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(sidekiq_password))
  end

  # Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
  mount Sidekiq::Web, at: "/sidekiq"

  get '/health', to: proc { [200, {}, ['']] }

  root to: 'swagger#index'
  get 'swagger' => 'swagger#index'

  devise_for  :users,
              :path => 'api/v1/users',
              :controllers => {
                registrations: 'api/v1/registrations',
                sessions: 'api/v1/sessions',
                passwords: 'api/v1/passwords',
                confirmations: 'api/v1/confirmations',
              }

  devise_scope :user do
    post 'api/v1/users/validate_email' => 'api/v1/registrations#validate_email'
    post 'api/v1/users/validate_nickname' => 'api/v1/registrations#validate_nickname'
  end

  def api_version(version, default = false, &routes)
    api_constraint = ApiConstraints.new(version: version, default: default)
    scope(module: "v#{version}", path: "v#{version}", constraints: api_constraint, &routes)
  end

  namespace :api, defaults: {format: :json} do
    api_version(1, true) do
      resources :boards do
      end

    end
  end



end
