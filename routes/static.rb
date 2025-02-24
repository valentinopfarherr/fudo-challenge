require "cuba"
require "json"

Static = Cuba.define do
  on get, "openapi.yaml" do
    res["content-type"] = "application/yaml"
    res["cache-control"] = "no-store, no-cache, must-revalidate, max-age=0"

    begin
      res.write File.read("public/openapi.yaml")
    rescue Errno::ENOENT
      res.status = 404
      res.write({ error: "Archivo no encontrado" }.to_json)
    end
  end

  on get, "AUTHORS" do
    res["content-type"] = "text/plain"
    res["cache-control"] = "public, max-age=86400"

    begin
      res.write File.read("public/AUTHORS")
    rescue Errno::ENOENT
      res.status = 404
      res.write({ error: "Archivo no encontrado" }.to_json)
    end
  end
end
