class ProductsController < AuthenticatedController

  def index
    @products = ShopifyAPI::Product.find(:all)
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
  end
  
  def create
    @product = ShopifyAPI::Product.new(product_params)   
    respond_to do |format|
      format.html do 
        if @product.save
          # image_params[:product_id] = @product.id
          @image = ShopifyAPI::Image.new(:product_id => @product.id)
          @image.attachment = params[:images].split(',')[1]
          @image.save
          redirect_to products_path
        end
      end
    end
  end
  
  def update
    @product = ShopifyAPI::Product.find(params[:id])
    @image = @product.images[0] || ShopifyAPI::Image.new(:product_id => @product.id)
    @image.attachment = params[:images].split(',')[1]
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params) and @image.save
          redirect_to products_path
        end
      end
    end
  end

  
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    
    @product.destroy
    
    respond_to do |format|
      format.html { render 'products#index', notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
    
  end

  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
    def image_params
      {
        :product_id => @product.id,
        :attachment => params[:images].split(',')[1]
      }
    end
    



end
