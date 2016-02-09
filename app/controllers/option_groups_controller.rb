class OptionGroupsController < ApplicationController
  def create
    @option_group = OptionGroup.new(:name => params[:option_group_name])
    if @option_group.save
      render json: { message: "created", id: @option_group.id }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def destroy
    @option_group = OptionGroup.find(params[:id])
    if @option_group.destroy
      redirect_to :back
    else
      render json: { message: "failed" }, :status => 500
    end
    
  end
  
end
