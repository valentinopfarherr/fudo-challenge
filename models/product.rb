require "json"
require_relative "../config/redis"

class Product
  REDIS = RedisConfig.client

  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name.strip
  end

  def self.all
    products = REDIS.lrange("products", 0, -1)
    products.map { |p| JSON.parse(p, symbolize_names: true) }
  end
  
  def self.add(name)
    id = REDIS.incr("product_id")
    product = { id: id, name: name.strip }

    REDIS.rpush("products", product.to_json) 
    product
  end

  def self.valid_name?(name)
    name = name.strip
    return { error: "El nombre del producto no puede estar vacío." } if name.empty?
    return { error: "El producto '#{name}' ya existe." } if exists?(name)
    { success: true }
  end

  def self.exists?(name)
    REDIS.lrange("products", 0, -1).any? do |p|
      product = JSON.parse(p, symbolize_names: true)
      product[:name].downcase == name.strip.downcase
    end
  end

  def self.clear_all
    REDIS.del("products")
  end
end
