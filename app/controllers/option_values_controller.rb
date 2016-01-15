class OptionValuesController < ApplicationController
  
  skip_before_action :verify_authenticity_token
   
  def assign_image
    @option_value = OptionValue.find(params[:option_value_id])
    @option_value.image = params[:image]
    @option_value.save
    render json: { message: "success" }, :status => 200
  end
  
  def unassign_image
  end
end
