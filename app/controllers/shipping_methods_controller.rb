class ShippingMethodsController < AuthenticatedController
  before_action :set_shipping_method, only: [:edit, :update, :destroy]
  
  def new
    @shipping_method = ShippingMethod.new
  end
  
  def edit
  end
  
  def create
    @shipping_method = ShippingMethod.new(shipping_method_params)
    if @shipping_method.save
      flash[:notice] = 'Shipping method was successfully created.'
      redirect_to root_url(protocol: 'https')
    else
      flash[:error] = @shipping_method.errors.full_messages
      redirect_to :back
    end
  end
  
  def update
    if @shipping_method.update_attributes(shipping_method_params)
      flash[:notice] =  'Shipping method was successfully updated.'
      redirect_to root_url(protocol: 'https')
    else
      flash[:error] = @shipping_method.errors.full_messages
      redirect_to :back
    end
  end
  
  def destroy
    @shipping_method.destroy
    flash[:notice] = 'Shipping method was successfully deleted'
    redirect_to root_url(protocol: 'https')
  end
  
  
  
  private
  
  def shipping_method_params
    params.require("shipping_method").permit(:name, :description, :lead_time, :lead_time_unit)
  end
  
  def set_shipping_method
    @shipping_method = ShippingMethod.find(params[:id])
  end
end