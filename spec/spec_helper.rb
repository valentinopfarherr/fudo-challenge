# frozen_string_literal: true

require_relative "../config/redis"
require "rack/test"
require "sidekiq/testing"

ENV["RACK_ENV"] ||= "test"

Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.before(:each) do
    raise "¡Peligro! Estás corriendo los tests fuera del entorno de pruebas." unless ENV["RACK_ENV"] == "test"

    RedisConfig.client.flushdb
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
