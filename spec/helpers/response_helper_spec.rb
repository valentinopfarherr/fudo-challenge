require "spec_helper"
require "rack/test"
require "zlib"
require "stringio"
require_relative "../../helpers/response_helper"
require_relative "../../helpers/gzip_helper"

describe ResponseHelper do
  include Rack::Test::Methods

  let(:mock_response) do
    instance_double("response").tap do |response|
      allow(response).to receive(:status=)
      allow(response).to receive(:[]=)
      allow(response).to receive(:write)
    end
  end

  let(:mock_request) do
    instance_double("request").tap do |request|
      allow(request).to receive(:get_header).with("HTTP_ACCEPT_ENCODING").and_return(nil)
    end
  end

  let(:gzip_request) do
    instance_double("request").tap do |request|
      allow(request).to receive(:get_header).with("HTTP_ACCEPT_ENCODING").and_return("gzip")
    end
  end

  def decompress_gzip(data)
    sio = StringIO.new(data)
    gz = Zlib::GzipReader.new(sio)
    gz.read
  ensure
    gz.close if gz
  end

  describe ".send_json" do
    it "devuelve JSON con código de estado correcto" do
      expect(mock_response).to receive(:status=).with(200)
      expect(mock_response).to receive(:[]=).with("content-type", "application/json")
      expect(mock_response).to receive(:write).with({ message: "Test exitoso" }.to_json)

      ResponseHelper.send_json(mock_response, { message: "Test exitoso" })
    end

    it "permite definir un código de estado diferente" do
      expect(mock_response).to receive(:status=).with(400)
      expect(mock_response).to receive(:write).with({ error: "Solicitud incorrecta" }.to_json)

      ResponseHelper.send_json(mock_response, { error: "Solicitud incorrecta" }, status: 400)
    end

    it "no comprime la respuesta si el cliente no soporta gzip" do
      expect(mock_response).to receive(:status=).with(200)
      expect(mock_response).to receive(:write).with({ message: "Sin compresión" }.to_json)

      ResponseHelper.send_json(mock_response, { message: "Sin compresión" }, req: mock_request)
    end

    it "comprime la respuesta si el cliente soporta gzip" do
      expect(mock_response).to receive(:status=).with(200)
      expect(mock_response).to receive(:[]=).with("content-encoding", "gzip")

      captured_gzip_data = nil
      allow(mock_response).to receive(:write) { |data| captured_gzip_data = data }

      ResponseHelper.send_json(mock_response, { message: "Con compresión" }, req: gzip_request)

      expect(decompress_gzip(captured_gzip_data)).to eq({ message: "Con compresión" }.to_json)
    end
  end
end
