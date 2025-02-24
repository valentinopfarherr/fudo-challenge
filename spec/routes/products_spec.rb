# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require_relative "../../routes/products"
require_relative "../../models/product"
require_relative "../../helpers/jwt_helper"

describe "Products Routes" do
  include Rack::Test::Methods

  def app
    Products
  end

  let(:valid_user) { User.create("test_user", "password123") }
  let(:valid_token) { "Bearer #{JwtHelper.encode({ user_id: valid_user[:id] })}" }
  let(:invalid_token) { "Bearer invalid_token" }

  before(:each) do
    Product.clear_all
  end

  describe "GET /products" do
    context "cuando no hay token" do
      it "devuelve 401" do
        get "/products"
        expect(last_response.status).to eq(401)
        expect(JSON.parse(last_response.body)["error"]).to eq("Token inválido o expirado")
      end
    end

    context "cuando el token es válido" do
      it "devuelve una lista vacía si no hay productos" do
        get "/products", {}, { "HTTP_AUTHORIZATION" => valid_token }
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq([])
      end

      it "devuelve una lista de productos si existen" do
        Product.add("Producto 1")
        Product.add("Producto 2")

        get "/products", {}, { "HTTP_AUTHORIZATION" => valid_token }

        expect(last_response.status).to eq(200)
        response_data = JSON.parse(last_response.body)
        expect(response_data.size).to eq(2)
        expect(response_data.map { |p| p["name"] }).to contain_exactly("Producto 1", "Producto 2")
      end
    end
  end

  describe "POST /products" do
    context "cuando no hay token" do
      it "devuelve 401" do
        post "/products", { name: "Nuevo Producto" }
        expect(last_response.status).to eq(401)
        expect(JSON.parse(last_response.body)["error"]).to eq("Token inválido o expirado")
      end
    end

    context "cuando el token es válido" do
      it "devuelve error 400 si el nombre del producto es inválido" do
        post "/products", { name: "" }, { "HTTP_AUTHORIZATION" => valid_token }
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)["error"]).to eq("El nombre del producto no puede estar vacío.")
      end

      it "devuelve error 409 si el producto ya existe" do
        Product.add("Producto Duplicado")

        post "/products", { name: "Producto Duplicado" }, { "HTTP_AUTHORIZATION" => valid_token }

        expect(last_response.status).to eq(409)
        expect(JSON.parse(last_response.body)["error"]).to eq("El producto 'Producto Duplicado' ya existe.")
      end

      it "responde correctamente cuando se encola un nuevo producto para creación" do
        post "/products", { name: "Producto Nuevo" }, { "HTTP_AUTHORIZATION" => valid_token }

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)["message"]).to eq("El producto 'Producto Nuevo' está en proceso de creación. Disponible en 5 segundos.")
      end
    end
  end
end
