class VariantImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
    
  def create
<<<<<<< HEAD
    three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    image = VariantImage.new(:image => params[:image], :three_sixty_image_id => three_sixty_image.id)
    if image.save
      render json: { message: "success", imageID: image.id }, :status => 200 
=======
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    @image = VariantImage.new(:azure_image => params[:azure_image], :three_sixty_image_id => @three_sixty_image.id)
    if @image.save
      render json: { message: "success", imageID: @image.id }, :status => 200 
>>>>>>> bf04443563d0d85d314d8f8e9f0d490754df3029
    end
  end
  
  def destroy
    @image = VariantImage.find(params[:id])
    if @image.destroy
      render json: { message: "deleted" }, :status => 200
    end
  end
end

