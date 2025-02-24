# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require_relative "../../app"
require_relative "../../models/user"
require_relative "../../models/product"
require_relative "../../helpers/jwt_helper"

describe "Full Integration Test", type: :request do
  include Rack::Test::Methods

  def app
    Cuba
  end

  let(:username) { "integration_user" }
  let(:password) { "securepassword" }
  let(:product_name) { "Producto de integración" }
  let(:invalid_product_name) { "" }

  before(:each) do
    User.clear_all
    Product.clear_all
  end

  it "ejecuta el flujo completo de autenticación y creación de productos" do
    post "/auth/register", username: "usuario_test", password: "password123"
    expect(last_response.status).to eq(200)
    
    post "/auth/login", username: "usuario_test", password: "password123"
    expect(last_response.status).to eq(200)
    token = JSON.parse(last_response.body)["token"]
    auth_header = { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
  
    post "/products", { name: "ProductoTest" }, auth_header
    expect(last_response.status).to eq(200)
  end
  
end
