class OptionsController < AuthenticatedController
  
  def new
    @option = Option.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
    # @option_value = OptionValue.find(params[:option_value_id])
  end
  
  def create
    
    if params[:commit] == 'Cancel'
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.new
    @option.name = params[:option][:name]
    @option.save
    1.upto(params[:number_of_option_values].to_i) do |i|
      unless params["option_value#{i}".to_sym] == ''
        @option_value = OptionValue.new(option_id:@option.id, value: params["option_value#{i}".to_sym])
        @option_value.save
      end
    end
    if @option.save
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
    end
  end
  
  def update
    if params[:commit] == 'Cancel'
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:product_id])
    @option = Option.find(params[:option_id])
    @option.name = params[:option][:name]
    @option.save
    1.upto(params[:number_of_option_values].to_i) do |i|
      unless params["option_value#{i}".to_sym] == ''
        @option_value = OptionValue.where(value: params["option_value#{i}".to_sym], option_id: @option.id)[0] || OptionValue.new(option_id:@option.id, value: params["option_value#{i}".to_sym])
        @option_value.save
      end
    end
    if @option.save
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
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
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
    end
  end
  
  def assign_option_to_product
    @option = Option.find(params[:option_id])
    if @option.products_options.create(:product_id => params[:product_id])
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def unassign_option_from_product
    @product_option = ProductsOption.where(:product_id => params[:product_id], :option_id => params[:option_id])[0]
    if @product_option.destroy
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end

  end
  
  def update_order_numbers_and_groups
    @options_order_and_groups = params["options_order_and_groups"]
    @options_order_and_groups.each do |option_name, order_number_and_group|
      @option = Option.where(:name => option_name)[0]
      @order_number = order_number_and_group["order_number"]
      @option_group_id = order_number_and_group["option_group_id"]
      if @option_group_id == 0 or @option_group_id == "0"
        @option.update_attributes(:order_number => @order_number)
      else
        @option.update_attributes(:order_number => @order_number, :option_group_id => @option_group_id)
      end
    end
    render json: { message: "created" }, :status => 200
  end
  
  private
  
  def option_params
    params.permit(:name)
  end
end
