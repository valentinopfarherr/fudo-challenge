require_relative "../helpers/jwt_helper"
require_relative "../models/user"
require_relative "../helpers/response_helper"

module AuthHelper
  def self.authenticate!(req, res)
    auth_header = req.env["HTTP_AUTHORIZATION"]
    token = auth_header&.split(" ")&.last

    unless token
      ResponseHelper.send_json(res, { error: "Token inválido o expirado" }, status: 401, req: req)
      return nil
    end

    decoded_token = JwtHelper.decode(token)

    unless decoded_token
      ResponseHelper.send_json(res, { error: "Token inválido o expirado" }, status: 401, req: req)
      return nil
    end

    user = User.find_by_id(decoded_token["user_id"])

    unless user
      ResponseHelper.send_json(res, { error: "Token inválido o expirado" }, status: 401, req: req)
      return nil
    end

    user
  end
end
