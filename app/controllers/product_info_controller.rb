class ProductInfoController < ApplicationController
  
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end

  def show
    @product_options = []
    ProductsOption.where(:product_id => params[:id]).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    #@product_options = Option.joins("inner join products_options on products_options.option_id = options.id").uniq
    @variants = Variant.where(product_id: params[:id])
    @first_image = ProductImage.where(product_id: params[:id]).first
    respond_to do |format|
      format.json { render status: :ok, :callback => params[:callback] }
    end
    
  end  
end