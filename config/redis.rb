require "redis"

module RedisConfig
  def self.client
    db = ENV["RACK_ENV"] == "test" ? 1 : 0
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/#{db}"))
  end
end