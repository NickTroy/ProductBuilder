class ColorRangesController < AuthenticatedController
  before_action :set_color_range, only: [:edit, :update, :destroy]
  
  def new
    @color_range = ColorRange.new
  end
  
  def edit
    @color = if @color_range.color.nil? or @color_range.color == "" 
      "#000000" 
    else
      @color_range.color
    end
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
  
  
  
  private
  
  def color_range_params
    params.require("color_range").permit(:name, :color)
  end
  
  def set_color_range
    @color_range = ColorRange.find(params[:id])
  end
end

