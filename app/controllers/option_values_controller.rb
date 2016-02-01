class OptionValuesController < ApplicationController
  
  skip_before_action :verify_authenticity_token
   
  def assign_image
    @option_value = OptionValue.find(params[:option_value_id])
    @option_value.image = params[:image]
    @option_value.save
    render json: { message: "success" }, :status => 200
  end
  
  def unassign_image
    @option_value = OptionValue.find(params[:option_value_id])
    @option_value.image.destroy
    @option_value.save
    render json: { message: "success" }, :status => 200
  end
  
  def destroy
    @option_value = OptionValue.find(params[:id])
    if @option_value.destroy
      redirect_to :back #edit_option_url(:id => params[:option_id], :protocol => 'https')
    else
      render json: { message: "failed"}, :status => 500
    end    
  end
end
