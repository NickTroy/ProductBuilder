class ProductImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  
  def create
    @product = ShopifyAPI::Product.find(params[:product_id])
    @image = ProductImage.new(image_params)
    if @image.save
      #respond_to do |format|
        render json: { message: "success", imageID: @image.id }, :status => 200 #{ redirect_to edit_product_path(@product.id)}#, :image_id => @image.id) }
      #end
    end
  end
  
  def destroy
    #@image = ShopifyAPI::Image.find(params[:image_id], :params => {:product_id => params[:product_id]})
    @image = ProductImage.find(params[:id])
    if @image.destroy
      redirect_to edit_product_path :id => params[:product_id] 
    end
  end
  
  private

    def image_params
      params.permit(:image_source, :title, :product_id, :image)
    end
    
end
