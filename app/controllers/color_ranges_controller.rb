class ColorRangesController < AuthenticatedController
  before_action :set_color_range, only: [:edit, :update, :destroy, :assign_option_values]
  
  def new
    @color_range = ColorRange.new
  end
  
  def edit
    @color = if @color_range.color.nil? or @color_range.color == "" 
      "#000000" 
    else
      @color_range.color
    end
    @color_range_option_values = @color_range.option_values
    @color_option_values = Option.find_by(name: "Color").option_values unless Option.find_by(name: "Color").nil?
    @color_option_values -= @color_range_option_values 
  end
  
  def create
    @color_range = ColorRange.new(color_range_params)
    if @color_range.save
      flash[:notice] = 'Color range was successfully created.'
      redirect_to root_url(protocol: 'https')
    else
      flash[:error] = @color_range.errors.full_messages
      redirect_to :back
    end
  end
  
  def update
    if @color_range.update_attributes(color_range_params)
      flash[:notice] =  'Color range was successfully updated.'
      redirect_to root_url(protocol: 'https')
    else
      flash[:error] = @color_range.errors.full_messages
      redirect_to :back
    end
  end
  
  def destroy
    @color_range.destroy
    flash[:notice] = 'Color range was successfully deleted'
    redirect_to root_url(protocol: 'https')
  end
  
  def assign_option_values
    option_values_ids = params[:option_values_ids]
    option_values_ids.each do |option_value_id|
      option_value = OptionValue.find(option_value_id)
      @color_range.option_values << option_value
    end
    render json: { message: "assigned" }, status: 200
  end
  
  def unassign_option_values
    option_values_ids = params[:option_values_ids]
    option_values_ids.each do |option_value_id|
      option_value = OptionValue.find(option_value_id)
      option_value.update_attributes(color_range_id: nil)
    end
    render json: { message: "unassigned" }, status: 200
  end
  
  private
  
  def color_range_params
    params.require("color_range").permit(:name, :color)
  end
  
  def set_color_range
    @color_range = ColorRange.find(params[:id])
  end
end

