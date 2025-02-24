# frozen_string_literal: true

require "spec_helper"
require "zlib"
require "stringio"
require_relative "../../helpers/gzip_helper"

describe GzipHelper do
  let(:data) { "Este es un texto de prueba para compresión Gzip." }

  describe ".compress" do
    it "comprime correctamente una cadena de texto" do
      compressed_data = GzipHelper.compress(data)
      
      expect(compressed_data).to be_a(String)
      expect(compressed_data).not_to eq(data) 

      sio = StringIO.new(compressed_data)
      gz = Zlib::GzipReader.new(sio)
      expect(gz.read).to eq(data)
    end
  end

  describe ".client_accepts_gzip?" do
    let(:request) { double("request", get_header: "gzip, deflate, br") }

    it "devuelve true si el cliente acepta gzip" do
      expect(GzipHelper.client_accepts_gzip?(request)).to be_truthy
    end

    it "devuelve false si el cliente no acepta gzip" do
      request_no_gzip = double("request", get_header: "deflate, br")
      expect(GzipHelper.client_accepts_gzip?(request_no_gzip)).to be_falsey
    end

    it "devuelve false si el encabezado es nil" do
      request_nil_header = double("request", get_header: nil)
      expect(GzipHelper.client_accepts_gzip?(request_nil_header)).to be_falsey
    end
  end
end
