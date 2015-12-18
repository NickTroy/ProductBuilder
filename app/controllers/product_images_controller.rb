class ProductImagesController < AuthenticatedController
  
  def create
    @product = ShopifyAPI::Product.find(params[:product_id])
    #@image = ShopifyAPI::Image.new(:product_id => @product.id)
    #@image.attachment = image_params[:image_url]
    #@image.name = image_params[:name]
    @image = ProductImage.new(image_params)
    if @image.save
      respond_to do |format|
        format.json { redirect_to edit_product_path(@product.id, :image_id => @image.id) }
      end
    end
  end
  
  def destroy
    #@image = ShopifyAPI::Image.find(params[:image_id], :params => {:product_id => params[:product_id]})
    @image = ProductImage.find(params[:image_id])
    if @image.destroy
      redirect_to edit_product_path :id => params[:product_id] 
    end
  end
  
  private

    def image_params
      params.permit(:image_source, :title, :product_id)
    end

end
