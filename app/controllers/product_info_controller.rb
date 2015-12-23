class ProductInfoController < ApplicationController
  def show
    @product_options = Option.joins("inner join products_options on products_options.option_id = options.id")
    @variants = Variant.where(product_id: params[:id])
    respond_to do |format|
      format.json { render 'show' }
    end
  end  
end
