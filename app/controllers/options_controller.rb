class OptionsController < AuthenticatedController
  
  def new
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
  end
  
  def create
    
    if params[:commit] == 'Cancel'
      redirect_to edit_product_path :id => params[:product_id]
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.new(option_params)
    @option.name = params[:option][:name]
    @option.save
    1.upto(params[:number_of_option_values].to_i) do |i|
      @option_value = OptionValue.new(option_id:@option.id, value:params["option_value#{i}".to_sym])
      @option_value.save
    end
    if @option.save
      redirect_to edit_product_path :id => params[:product_id]
    end
  end
  
  def update
    if params[:commit] == 'Cancel'
      redirect_to edit_product_path :id => params[:product_id]
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
    @option.name = params[:option][:name]
    @option.save
    1.upto(params[:number_of_option_values].to_i) do |i|
      @option_value = OptionValue.where(value: params["option_value#{i}".to_sym])[0] || OptionValue.new(option_id:@option.id, value: params["option_value#{i}".to_sym])
      @option_value.save
    end
    if @option.save
      redirect_to edit_product_path :id => params[:product_id]
    end
    
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
    
    if @option.destroy
      redirect_to edit_product_path :id => params[:product_id]
    end
  end
  
  private
  
  def option_params
    params.permit(:product_id, :name)
  end
end
