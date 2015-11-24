class ProductsController < AuthenticatedController

  def index
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
  end

  def new
    @product = ShopifyAPI::Product.new
  end

  def create
    @product = ShopifyAPI::Product.new
    @product.title = params[:title]
    if @product.save
      redirect_to products_path
    end
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    
    @product.destroy
    
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
    
  end

  private

=begin
    def product_params
      params.require(:product).permit(:body_html, :handle, :images, :options, 
                                      :product_type, :published_scope, :tags,
                                      :template_suffix, :title, :variants, :vendor)
    end
=end


end
