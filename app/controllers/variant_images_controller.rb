class VariantImagesController < ApplicationController
  skip_before_action :verify_authenticity_token
    
  def create
    @variant = Variant.find(params[:variant_id])
    @image = VariantImage.new(:image => params[:image], :variant_id => @variant.id)
    if @image.save
      render json: { message: "success", imageID: @image.id }, :status => 200 
    end
  end
  
  def destroy
    @image = VariantImage.find(params[:id])
    if @image.destroy
      render json: { message: "deleted" }, :status => 200
    end
  end
end

