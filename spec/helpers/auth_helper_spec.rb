# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require_relative "../../helpers/auth_helper"
require_relative "../../helpers/jwt_helper"
require_relative "../../models/user"

describe AuthHelper do
  include Rack::Test::Methods

  let(:valid_user) { User.create("test_user", "password123") }
  let(:valid_token) { "Bearer #{JwtHelper.encode({ user_id: valid_user[:id] })}" }
  let(:invalid_token) { "Bearer invalid_token" }
  let(:expired_token) { "Bearer #{JwtHelper.encode({ user_id: valid_user[:id], exp: Time.now.to_i - 10 })}" }

  let(:mock_request) do
    double("request", env: {}).tap do |request|
      allow(request).to receive(:get_header).with("HTTP_ACCEPT_ENCODING").and_return(nil)
    end
  end
  
  let(:mock_response) do
    instance_double("response", status: nil, write: nil).tap do |response|
      allow(response).to receive(:[]=) 
    end
  end

  before(:each) do
    User.clear_all
  end

  describe ".authenticate!" do
    it "devuelve el usuario si el token es válido" do
      allow(mock_request).to receive(:env).and_return({ "HTTP_AUTHORIZATION" => valid_token })
      allow(User).to receive(:find_by_id).with(valid_user[:id]).and_return(valid_user)

      expect(AuthHelper.authenticate!(mock_request, mock_response)).to eq(valid_user)
    end

    it "devuelve error si no hay token" do
      allow(mock_request).to receive(:env).and_return({})
      expect(mock_response).to receive(:status=).with(401)
      expect(mock_response).to receive(:write).with({ error: "Token inválido o expirado" }.to_json)

      expect(AuthHelper.authenticate!(mock_request, mock_response)).to be_nil
    end

    it "devuelve error si el token es inválido" do
      allow(mock_request).to receive(:env).and_return({ "HTTP_AUTHORIZATION" => invalid_token })
      allow(JwtHelper).to receive(:decode).and_return(nil)

      expect(mock_response).to receive(:status=).with(401)
      expect(mock_response).to receive(:write).with({ error: "Token inválido o expirado" }.to_json)

      expect(AuthHelper.authenticate!(mock_request, mock_response)).to be_nil
    end

    it "devuelve error si el token está expirado" do
      allow(mock_request).to receive(:env).and_return({ "HTTP_AUTHORIZATION" => expired_token })
      allow(JwtHelper).to receive(:decode).and_return(nil)

      expect(mock_response).to receive(:status=).with(401)
      expect(mock_response).to receive(:write).with({ error: "Token inválido o expirado" }.to_json)

      expect(AuthHelper.authenticate!(mock_request, mock_response)).to be_nil
    end

    it "devuelve error si el usuario no existe" do
      allow(mock_request).to receive(:env).and_return({ "HTTP_AUTHORIZATION" => valid_token })
      allow(User).to receive(:find_by_id).and_return(nil)

      expect(mock_response).to receive(:status=).with(401)
      expect(mock_response).to receive(:write).with({ error: "Token inválido o expirado" }.to_json)

      expect(AuthHelper.authenticate!(mock_request, mock_response)).to be_nil
    end
  end
end
