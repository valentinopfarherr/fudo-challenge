require "cuba"
require "json"
require_relative "../models/user"
require_relative "../helpers/gzip_helper"
require_relative "../helpers/jwt_helper"

Auth = Cuba.define do
  on post, "register" do
    on param("username"), param("password") do |username, password|
      if username.strip.empty? || password.strip.empty?
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

    ResponseHelper.send_json(res, { error: "Faltan parámetros: 'username' y 'password'" }, status: 400, req: req)
  end

  on post, "login" do
    on param("username"), param("password") do |username, password|
      if username.nil? || password.nil? || username.strip.empty? || password.strip.empty?
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
    ResponseHelper.send_json(res, { error: "Faltan parámetros: 'username' y 'password'" }, status: 400, req: req)
  end
end
