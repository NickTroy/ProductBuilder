class ProductsController < AuthenticatedController

  def index
    @products = ShopifyAPI::Product.find(:all)
    @variants = Variant.all
    @images = ProductImage.all
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: @product.id)
    @options = Option.all
    @product_options = Option.joins("inner join products_options on products_options.option_id = options.id")
    #ProductsOption.where(product_id: params[:id])
    @variants = Variant.where(product_id: @product.id)
  end
  
  def show
    @product = ShopifyAPI::Product.find(params[:id])
    @product_options = Option.joins("inner join products_options on products_options.option_id = options.id")
    @variants = Variant.where(product_id: @product.id)
    #respond_to do |format|
     # format.json { render 'show.json.jbuilder' }
    #end
  end
  
  def create
    @product = ShopifyAPI::Product.new(product_params)   
    respond_to do |format|
      format.html do 
        if @product.save
          redirect_to edit_product_path :id => @product.id
        end
      end
    end
  end
  
  def update
    @product = ShopifyAPI::Product.find(params[:id])
    
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params)
          redirect_to products_path
        end
      end
    end
  end

  
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: params[:id])
    @variants = Variant.where(product_id: params[:id])
    @product_options = Option.where(product_id: params[:id])
    @images.each { |img| img.destroy }
    @variants.each { |var| var.destroy }
    @options.each { |opt| opt.destroy }
    @product.destroy
    
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Product was successfully deleted.' }
    end
    
  end

  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
end
