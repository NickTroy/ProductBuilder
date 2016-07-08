class OptionGroupsController < ApplicationController
  def create
    @option_group = OptionGroup.new(option_group_params)
    if @option_group.save
      render json: { message: "created", id: @option_group.id, name: @option_group.name, prefix: @option_group.prefix }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def update
    @option_group = OptionGroup.find(params[:id])
    if @option_group.update_attributes(option_group_params)
      render json: { message: "updated" }, :status => 200
    else 
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def destroy
    @option_group = OptionGroup.find(params[:id])
    if @option_group.destroy
      render json: { message: "deleted" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
    
  end
  
  private
  
  def option_group_params
    params.permit(:name, :prefix)
  end
  
end
