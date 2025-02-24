require "spec_helper"
require "sidekiq/testing"
require_relative "../../workers/product_worker"
require_relative "../../models/product"

Sidekiq::Testing.fake! 

describe ProductWorker do
  before(:each) do
    Product.clear_all
  end

  it "agrega un nuevo producto si no existe" do
    expect(Product.exists?("Nuevo Producto")).to be false

    ProductWorker.new.perform("Nuevo Producto")

    expect(Product.exists?("Nuevo Producto")).to be true
  end

  it "no duplica productos existentes" do
    Product.add("Producto Duplicado")

    expect { ProductWorker.new.perform("Producto Duplicado") }
      .not_to(change { Product.all.size })
  end

  it "maneja errores sin crashear" do
    allow(Product).to receive(:add).and_raise(StandardError.new("Error simulado"))

    expect(Sidekiq.logger).to receive(:error).with(/Error creando producto: Error simulado/)

    expect { ProductWorker.new.perform("Producto Erroneo") }
      .not_to raise_error
  end

  it "se encola correctamente en Sidekiq" do
    expect {
      ProductWorker.perform_async("Producto en cola")
    }.to change(ProductWorker.jobs, :size).by(1)
  end
end
