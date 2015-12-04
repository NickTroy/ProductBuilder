class OptionsController < AuthenticatedController
  def create
    @product = ShopifyAPI::Product.find(params[:product_id])
    options = []
    1.upto(5) do |i|
      name = "option#{i}name".to_sym
      value = "option#{i}value".to_sym
      type = "option#{i}type".to_sym
      options.push([name,value,type])
    end
    options.each do |opt|
      @product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "option", 
                                                     :key => params[opt[0]], 
                                                     :value => params[opt[1]], 
                                                     :value_type => params[opt[2]]))
      @product.save
    end
    
    
    respond_to do |format|
      format.html{ redirect_to edit_product_path(@product.id) }
    end
  end
  
  def destroy
    @option = ShopifyAPI::Metafield.find(params[:option_id])
    @product = ShopifyAPI::Product.find(params[:product_id])
    if @option.destroy
      redirect_to edit_product_path(@product.id)
    end
  end
end
