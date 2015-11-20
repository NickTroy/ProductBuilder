class ProductsController < ApplicationController

  def index
    @products = ShopifyAPI::Product.all
  end

end
