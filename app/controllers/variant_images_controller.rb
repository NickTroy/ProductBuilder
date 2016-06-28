class VariantImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
    
  def create
    three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    image = VariantImage.new(:image => params[:image], :three_sixty_image_id => three_sixty_image.id)
    if image.save
      render json: { message: "success", imageID: image.id }, :status => 200 
    end
  end
  
  def destroy
    @image = VariantImage.find(params[:id])
    if @image.destroy
      render json: { message: "deleted" }, :status => 200
    end
  end
end

