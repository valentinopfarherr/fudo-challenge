# frozen_string_literal: true

require "json"

module RequestHelper # rubocop:disable Style/Documentation
  def self.extract_params(req)
    params = req.params.dup
    if req.env["CONTENT_TYPE"]&.include?("application/json")
      begin
        body_params = JSON.parse(req.body.read)
        params.merge!(body_params) if body_params.is_a?(Hash)
      rescue JSON::ParserError
        return nil, "El cuerpo de la solicitud no es un JSON válido."
      end
    end
    [params, nil]
  end
end
