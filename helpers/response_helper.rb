require "json"
require_relative "./gzip_helper"

module ResponseHelper
  def self.send_json(res, data, status: 200, req: nil)
    res.status = status
    res["content-type"] = "application/json"

    json_response = data.to_json

    if req && GzipHelper.client_accepts_gzip?(req)
      res["content-encoding"] = "gzip"
      res.write GzipHelper.compress(json_response)
    else
      res.write json_response
    end
  end
end
