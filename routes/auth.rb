require "cuba"
require "json"
require_relative "../models/user"
require_relative "../helpers/gzip_helper"
require_relative "../helpers/jwt_helper"
require_relative "../helpers/response_helper"
require_relative "../helpers/request_helper"

Auth = Cuba.define do # rubocop:disable Metrics/BlockLength
  on post, "register" do
    params, error = RequestHelper.extract_params(req)
    if error
      ResponseHelper.send_json(res, { error: error }, status: 400, req: req)
      next
    end

    username = params["username"]&.strip
    password = params["password"]&.strip

    if username.nil? || username.empty? || password.nil? || password.empty?
      ResponseHelper.send_json(res, { error: "El nombre de usuario y la contraseña son obligatorios" }, status: 400, req: req)
      next
    end

    user = User.create(username, password)

    if user[:error]
      ResponseHelper.send_json(res, user, status: 400, req: req)
    else
      ResponseHelper.send_json(res, { id: user[:id], username: user[:username], message: "Usuario registrado exitosamente" }, req: req)
    end
  end

  on post, "login" do
    params, error = RequestHelper.extract_params(req)
    if error
      ResponseHelper.send_json(res, { error: error }, status: 400, req: req)
      next
    end

    username = params["username"]&.strip
    password = params["password"]&.strip

    if username.nil? || username.empty? || password.nil? || password.empty?
      ResponseHelper.send_json(res, { error: "El nombre de usuario y la contraseña son obligatorios" }, status: 400, req: req)
      next
    end

    user = User.find_by_username(username)

    if user && user.authenticate(password)
      token = JwtHelper.encode({ user_id: user.id })
      ResponseHelper.send_json(res, { token: token }, req: req)
    else
      ResponseHelper.send_json(res, { error: "Credenciales inválidas" }, status: 401, req: req)
    end
  end
end
