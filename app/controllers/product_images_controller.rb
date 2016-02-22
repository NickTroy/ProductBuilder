class ProductImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  
  def create
    @image = ProductImage.new(image_params)
    if @image.save
      render json: { message: "success", imageID: @image.id }, :status => 200
    else 
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def destroy
    @image = ProductImage.find(params[:id])
    if @image.destroy 
      render json: { message: "destroyed" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
    
  end
  
  private

    def image_params
      params.permit(:image_source, :title, :product_id, :image)
    end
    
end
