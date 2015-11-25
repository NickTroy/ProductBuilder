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
  
  def update
    @product = ShopifyAPI::Product.find(params[:id])
    
    respond_to do |format|
      format.html do 
        if @product.save(product_params)
          redirect_to products_path
        end
      end
    end
  end

  def create
    @product = ShopifyAPI::Product.new(product_params)   
    
    respond_to do |format|
      format.html do 
        if @product.save
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
      format.json { head :no_content }
    end
    
  end

  private

    def product_params
      params.permit(:body_html, :handle, :images, :options, 
                                      :product_type, :published_scope, :tags,
                                      :template_suffix, :title, :variants, :vendor)
    end



end
