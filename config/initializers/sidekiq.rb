frozen_string_literal: true

namespace = Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq_redis, :redis_namespace) { nil }
redis_params = { url: Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq_redis, :redis_url) }

if namespace
  redis_params[:namespace] = namespace
end

Sidekiq.configure_server do |config|
  config.redis = redis_params
  schedule_file = "config/schedule.yml"
  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_params
end

Sidekiq::Extensions.enable_delay!
