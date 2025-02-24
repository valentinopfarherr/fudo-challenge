require "sidekiq"
Dir["./app/workers/*.rb"].each { |file| require file }

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://cuba_redis:6379/0") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://cuba_redis:6379/0") }
end
