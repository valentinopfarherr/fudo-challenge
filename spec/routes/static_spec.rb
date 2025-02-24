require "spec_helper"
require "rack/test"
require_relative "../../routes/static"

describe "Static Routes" do
  include Rack::Test::Methods

  def app
    Static
  end

  let(:openapi_path) { "public/openapi.yaml" }
  let(:authors_path) { "public/AUTHORS" }

  before(:each) do
    allow(File).to receive(:read).with(openapi_path).and_return("openapi: 3.0.0")
    allow(File).to receive(:read).with(authors_path).and_return("Author: John Doe")
  end

  describe "GET /openapi.yaml" do
    it "devuelve el archivo openapi.yaml con el tipo de contenido correcto" do
      get "/openapi.yaml"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["content-type"]).to eq("application/yaml")
      expect(last_response.headers["cache-control"]).to eq("no-store, no-cache, must-revalidate, max-age=0")
      expect(last_response.body).to eq("openapi: 3.0.0")
    end

    it "devuelve 404 si el archivo no existe" do
      allow(File).to receive(:read).with(openapi_path).and_raise(Errno::ENOENT)

      get "/openapi.yaml"

      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)["error"]).to eq("Archivo no encontrado")
    end
  end

  describe "GET /AUTHORS" do
    it "devuelve el archivo AUTHORS con el tipo de contenido correcto" do
      get "/AUTHORS"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["content-type"]).to eq("text/plain")
      expect(last_response.headers["cache-control"]).to eq("public, max-age=86400")
      expect(last_response.body).to eq("Author: John Doe")
    end

    it "devuelve 404 si el archivo no existe" do
      allow(File).to receive(:read).with(authors_path).and_raise(Errno::ENOENT)

      get "/AUTHORS"

      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body)["error"]).to eq("Archivo no encontrado")
    end
  end
end
