class ProductsController < AuthenticatedController

  def index
    @products = ShopifyAPI::Product.find(:all)
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
    @images = @product.images
    @options = Option.where(product_id: @product.id)
    @variants = Variant.where(product_id: @product.id)
    #@images_urls = ""
    #@images.each { |img| @images_urls += img.src + ','}
  end
  
  def create
    @product = ShopifyAPI::Product.new(product_params)   
    respond_to do |format|
      format.html do 
        if @product.save
          @urls_of_images = params[:images].split(',')
          @urls_of_images.delete("") if @urls_of_images[0] == "" 
          @urls_of_images.each do |url|
            @image = ShopifyAPI::Image.new(:product_id => @product.id)
            @image.attachment = url
            @image.save
          end
          
          redirect_to products_path
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
