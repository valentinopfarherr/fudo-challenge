require "cuba"
require "sidekiq"
require_relative "routes/products"
require_relative "routes/auth"
require_relative "routes/static"
require_relative "./workers/product_worker"

Cuba.define do
  on root do
    res.write "Fudo Challenge"
  end

  on "products" do
    run Products
  end

  on "auth" do
    run Auth
  end

  on "static" do 
    run Static
  end
end
