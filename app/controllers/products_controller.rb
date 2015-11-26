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
    @product.images.push({
      "attachment": product_params[:images]
    })
    respond_to do |format|
      format.html do 
        if @product.save
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
      format.html { render 'products#index', notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
    
  end

  private

    def product_params
      params.permit(:body_html, :handle, :images, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
    def image_params
      { 
        image: 
        {
          attachment: product_params[:images]
        },
        product_id: params[:id]
      }  
    end
    



end
