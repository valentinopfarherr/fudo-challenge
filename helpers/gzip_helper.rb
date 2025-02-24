require "zlib"
require "stringio"

module GzipHelper
  def self.compress(data)
    sio = StringIO.new
    gz = Zlib::GzipWriter.new(sio)
    gz.write(data)
    gz.close
    sio.string
  end

  def self.client_accepts_gzip?(req)
    req.get_header("HTTP_ACCEPT_ENCODING")&.include?("gzip") 
  end
end
