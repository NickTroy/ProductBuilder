class SliderImagesParamsController < ApplicationController
  def create
    @slider_images_param = SliderImagesParam.new(:product_type => params[:product_type], :base_size_ratio => params[:base_size_ratio])
    if @slider_images_param.save
      render json: { message: "success", slider_images_param_id: @slider_images_param.id }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def destroy
    @slider_images_param = SliderImagesParam.find(params[:slider_images_param_id])
    if @slider_images_param.destroy
      render json: { message: "deleted" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
end
