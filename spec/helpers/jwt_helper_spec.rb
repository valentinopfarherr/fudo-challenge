# frozen_string_literal: true

require "spec_helper"
require "jwt"
require_relative "../../helpers/jwt_helper"

describe JwtHelper do
  let(:payload) { { user_id: 1 } }
  let(:token) { JwtHelper.encode(payload) }

  describe ".encode" do
    it "genera un token JWT válido" do
      expect(token).to be_a(String)
      expect(token.split(".").size).to eq(3)  
    end
  end

  describe ".decode" do
    it "decodifica un token JWT válido" do
      decoded = JwtHelper.decode(token)
      expect(decoded).to be_a(Hash)
      expect(decoded["user_id"]).to eq(1)
    end

    it "retorna nil si el token es inválido" do
      invalid_token = "invalid.token.value"
      expect(JwtHelper.decode(invalid_token)).to be_nil
    end

    it "retorna nil si el token ha expirado" do
      expired_token = JwtHelper.encode(payload, -10)
      expect(JwtHelper.decode(expired_token)).to be_nil
    end
  end
end
