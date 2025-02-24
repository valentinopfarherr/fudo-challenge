require "cuba"
require "json"
require_relative "../helpers/response_helper"
require_relative "../models/product"
require_relative "../workers/product_worker"
require_relative "../helpers/auth_helper"
require_relative "../helpers/request_helper"

Products = Cuba.define do
  on get do
    user = AuthHelper.authenticate!(req, res)
    next unless user

    products = Product.all
    ResponseHelper.send_json(res, products, req: req)
  end

  on post do
    user = AuthHelper.authenticate!(req, res)
    next unless user

    params, error = RequestHelper.extract_params(req)
    if error
      ResponseHelper.send_json(res, { error: error }, status: 400, req: req)
      next
    end

    name = params["name"]&.strip

    if name.nil? || name.empty?
      ResponseHelper.send_json(res, { error: "El nombre del producto es obligatorio." }, status: 400, req: req)
      next
    end

    if Product.exists?(name)
      ResponseHelper.send_json(res, { error: "El producto '#{name}' ya existe." }, status: 409, req: req)
    else
      begin
        ProductWorker.perform_async(name)
        ResponseHelper.send_json(res, { message: "El producto '#{name}' está en proceso de creación. Disponible en 5 segundos." }, req: req)
      rescue StandardError => e
        ResponseHelper.send_json(res, { error: "Error al procesar la solicitud: #{e.message}" }, status: 500, req: req)
      end
    end
  end
end
