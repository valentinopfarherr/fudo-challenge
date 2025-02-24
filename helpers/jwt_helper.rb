require "jwt"

SECRET_KEY = ENV.fetch("SECRET_KEY") { "fallback_key" }

module JwtHelper
  def self.encode(payload, exp = 24 * 3600) 
    payload[:exp] = Time.now.to_i + exp
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    decoded[0] 
  rescue JWT::DecodeError
    nil
  end
end