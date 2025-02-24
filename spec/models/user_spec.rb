# frozen_string_literal: true

require "spec_helper"
require_relative "../../models/user"

RSpec.describe User do
  let(:username) { "test_user" }
  let(:password) { "password123" }
  let(:user) { User.create(username, password) }

  before(:each) do
    User.clear_all
    @user = user
  end

  describe ".create" do
    it "crea un usuario con username y password" do
      expect(user).to be_a(Hash)
      expect(user[:username]).to eq(username)
    end

    it "no permite crear usuarios duplicados" do
      User.create(username, password)
      duplicate_user = User.create(username, password)
      expect(duplicate_user[:error]).to eq("El usuario '#{username}' ya existe")
    end

    it "no permite crear usuario sin username" do
      user = User.create("", password)
      expect(user[:error]).to eq("El nombre de usuario no puede estar vacío")
    end

    it "no permite crear usuario sin password" do
      user = User.create(username, "")
      expect(user[:error]).to eq("La contraseña no puede estar vacía")
    end
  end

  describe ".find_by_username" do
    it "encuentra un usuario por su username" do
      user
      found_user = User.find_by_username(username)
      expect(found_user).not_to be_nil
      expect(found_user.username).to eq(username)
    end

    it "devuelve nil si el usuario no existe" do
      expect(User.find_by_username("inexistente")).to be_nil
    end
  end

  describe ".find_by_id" do
    it "encuentra un usuario por su ID" do
      found_user = User.find_by_id(@user[:id])
      expect(found_user).not_to be_nil
      expect(found_user.username).to eq(username)
    end
  end
 
  describe "#authenticate" do
    let(:found_user) { User.find_by_id(@user[:id]) }

    it "autentica con la contraseña correcta" do
      expect(found_user.authenticate(password)).to be_truthy
    end

    it "rechaza autenticación con contraseña incorrecta" do
      expect(found_user.authenticate("wrongpassword")).to be_falsey
    end
  end
end
