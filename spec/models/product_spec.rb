# frozen_string_literal: true

require "spec_helper"
require_relative "../../models/product"

RSpec.describe Product do
  before(:each) do
    Product.clear_all
  end

  describe ".valid_name?" do
    it "devuelve error si el nombre está vacío" do
      expect(Product.valid_name?("")).to eq({ error: "El nombre del producto no puede estar vacío." })
    end

    it "devuelve error si el nombre es solo espacios" do
      expect(Product.valid_name?("   ")).to eq({ error: "El nombre del producto no puede estar vacío." })
    end

    it "devuelve success: true si el nombre es válido" do
      expect(Product.valid_name?("Producto1")).to eq({ success: true })
    end
  end

  describe ".exists?" do
    it "devuelve false si el producto no existe" do
      expect(Product.exists?("NuevoProducto")).to be false
    end

    it "devuelve true si el producto ya existe" do
      Product.add("ProductoExistente")
      expect(Product.exists?("ProductoExistente")).to be true
    end
  end

  describe ".add" do
    it "agrega un producto correctamente" do
      Product.add("ProductoNuevo")
      expect(Product.all.map { |p| p[:name] }).to include("ProductoNuevo")
    end
  end
end
