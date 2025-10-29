# frozen_string_literal: true

# REDIS_URL - setup by HatchBox
redis_url = ENV['REDIS_URL'].presence || ENV['REDIS_SERVER_URL'].presence || 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
