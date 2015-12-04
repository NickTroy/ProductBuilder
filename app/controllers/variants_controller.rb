class VariantsController < AuthenticatedController
  def create
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variant = ShopifyAPI::Variant.new(:product_id => @product.id)
    @variant.price = params[:price].to_i
    @variant.option1 = Time.now.to_i
    @variant.save
    @variant.add_metafield(ShopifyAPI::Metafield.new(:namespace => "variant", 
                                                     :key => params[:option0name], 
                                                     :value => params[:option0value], 
                                                     :value_type => params[:option0type]))
    @variant.save
    respond_to do |format|
      format.html{ redirect_to edit_product_path(@product.id) }
    end
  end
  
  private
  
    
    
    
end
