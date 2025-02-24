# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require_relative "../../routes/auth"
require_relative "../../models/user"
require_relative "../../helpers/jwt_helper"
require_relative "../../helpers/response_helper"

describe "Auth Routes" do
  include Rack::Test::Methods

  def app
    Auth
  end

  before(:each) do
    User.clear_all
  end

  let(:valid_username) { "test_user" }
  let(:valid_password) { "password123" }

  describe "POST /auth/register" do
    context "cuando se proporcionan datos válidos" do
      it "crea un nuevo usuario y devuelve un mensaje de éxito" do
        post "/register", username: valid_username, password: valid_password

        expect(last_response.status).to eq(200)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data[:username]).to eq(valid_username)
        expect(response_data[:message]).to eq("Usuario registrado exitosamente")
      end
    end

    context "cuando faltan parámetros" do
      it "devuelve un error si falta el username" do
        post "/register", password: valid_password

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end

      it "devuelve un error si falta el password" do
        post "/register", username: valid_username

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end

      it "devuelve un error si username y password están vacíos" do
        post "/register", username: "", password: ""

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end
    end
  end

  describe "POST /auth/login" do
    before(:each) do
      User.create(valid_username, valid_password)
    end

    context "cuando las credenciales son correctas" do
      it "devuelve un token de autenticación" do
        post "/login", username: valid_username, password: valid_password

        expect(last_response.status).to eq(200)
        response_data = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_data).to have_key(:token)
        expect(response_data[:token]).not_to be_nil
      end
    end

    context "cuando las credenciales son incorrectas" do
      it "devuelve un error si la contraseña es incorrecta" do
        post "/login", username: valid_username, password: "wrongpassword"

        expect(last_response.status).to eq(401)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Credenciales inválidas")
      end

      it "devuelve un error si el usuario no existe" do
        post "/login", username: "nonexistent", password: valid_password

        expect(last_response.status).to eq(401)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Credenciales inválidas")
      end
    end

    context "cuando faltan parámetros" do
      it "devuelve un error si falta el username" do
        post "/login", password: valid_password

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end

      it "devuelve un error si falta el password" do
        post "/login", username: valid_username

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end

      it "devuelve un error si username y password están vacíos" do
        post "/login", username: "", password: ""

        expect(last_response.status).to eq(400)
        response_data = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_data[:error]).to eq("Faltan parámetros: 'username' y 'password'")
      end
    end
  end
end
