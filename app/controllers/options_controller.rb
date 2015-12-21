class OptionsController < AuthenticatedController
  
  def new
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
  
  def show
    @option = Option.find(params[:id])
    @option_values = @option.option_values
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
    
    if @option.destroy
      redirect_to edit_product_path :id => params[:product_id]
    end
  end
  
  def assign_option_to_product
    @option = Option.find(params[:option_id])
    @option.products_options.create(:product_id => params[:product_id])
    
    redirect_to edit_product_path :id => params[:product_id]
  end
  
  def unassign_option_from_product
    @product_option = ProductsOption.where(:product_id => params[:product_id], :option_id => params[:option_id])[0]
    @product_option.destroy
    
    redirect_to edit_product_path :id => params[:product_id]
  end
  
  private
  
  def option_params
    params.permit(:name)
  end
end
