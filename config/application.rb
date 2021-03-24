require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IhavecatApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.eager_load_paths << Rails.root.join('lib')
    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = "Seoul"
    config.active_record.default_timezone = :local
    config.encoding = "utf-8"
    config.i18n.available_locales = [:en, :ko]
    config.i18n.default_locale = :ko

    config.generators.system_tests = nil
    config.middleware.use ActionDispatch::Flash
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins   '*'
        resource  '/api/*',
                  headers: :any,
                  methods: %i[post put delete get patch options],
                  credentials: false,
                  expose: [
                    'Link',
                    'X-RateLimit-Reset',
                    'X-RateLimit-Limit',
                    'X-RateLimit-Remaining', 'X-Request-Id'
                  ]
      end
    end

    config.filter_parameters << :password

  end
end
