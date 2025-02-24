require "sidekiq"
require_relative "../models/product"

class ProductWorker
  include Sidekiq::Worker

  def perform(name)
    sleep 5

    if Product.exists?(name)
      Sidekiq.logger.info "El producto '#{name}' ya existe. No se creará nuevamente."
      return
    end

    Product.add(name)
    Sidekiq.logger.info "Producto '#{name}' creado exitosamente."
  rescue StandardError => e
    Sidekiq.logger.error "Error creando producto: #{e.message}"
  end
end
