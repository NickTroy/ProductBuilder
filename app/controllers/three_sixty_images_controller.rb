class ThreeSixtyImagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @variant = Variant.find(params[:variant_id])
    @three_sixty = @variant.three_sixty_image || ThreeSixtyImage.new(:variant_id => params[:variant_id])
    @images = []
    params[:three_sixty_images].each do |number, img|
      @images.push(img)
    end
    if @three_sixty.plane_images.any?
      @three_sixty.plane_images.each do |plane_image|
        plane_image.destroy
      end
    end
    @images.each do |img|
      PlaneImage.create(:three_sixty_image_id => @three_sixty.id, :image => img)
    end
    if @three_sixty.save
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end

  def destroy
    @variant = Variant.find(params[:variant_id])
    @three_sixty = @variant.three_sixty_image
    if @three_sixty.destroy
      redirect_to :back
    else
      render json: { message: "failed" }, :status => 500
    end
  end
end
