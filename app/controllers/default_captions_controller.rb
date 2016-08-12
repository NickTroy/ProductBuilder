class DefaultCaptionsController < ApplicationController
  
  def index
  end

  def update
    params_ids = params[:ids].split(' ')
    params_ids.map do |id|
      value = params[id.to_sym]
      DefaultCaption.find(id.to_i).update_attribute(:default_caption, value)
    end
    render json: { message: "success" }, :status => 200
  end
  
end
