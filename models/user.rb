require "bcrypt"
require "json"
require_relative "../config/redis"
require_relative "../helpers/jwt_helper"

class User
  REDIS = RedisConfig.client

  attr_accessor :id, :username, :password_digest

  def initialize(id, username, password_digest)
    @id = id
    @username = username
    @password_digest = password_digest
  end

  def authenticate(password)
    BCrypt::Password.new(password_digest) == password
  end

  def self.all
    users = REDIS.lrange("users", 0, -1)
    users.map { |u| JSON.parse(u, symbolize_names: true) }
  end

  def self.find_by_username(username)
    user_data = all.find { |u| u[:username] == username.strip.downcase }
    return nil unless user_data
  
    User.new(user_data[:id], user_data[:username], user_data[:password_digest])
  end

  def self.find_by_id(id)
    user_data = all.find { |u| u[:id].to_i == id.to_i }
    return nil unless user_data
  
    User.new(user_data[:id], user_data[:username], user_data[:password_digest])
  end

  def self.create(username, password)
    return { error: "El nombre de usuario no puede estar vacío" } if username.nil? || username.strip.empty?
    return { error: "La contraseña no puede estar vacía" } if password.nil? || password.strip.empty?

    normalized_username = username.strip.downcase
    return { error: "El usuario '#{username}' ya existe" } if find_by_username(normalized_username)

    id = REDIS.incr("user_id")
    password_digest = BCrypt::Password.create(password)
    user = { id: id, username: normalized_username, password_digest: password_digest }

    REDIS.rpush("users", user.to_json)
    user
  end

  def self.exists?(username)
    REDIS.hexists("users_hash", username.strip.downcase)
  end

  def self.clear_all
    REDIS.del("products")
  end
end
