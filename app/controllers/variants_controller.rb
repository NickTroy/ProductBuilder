class VariantsController < AuthenticatedController

  def index
    @variants = Variant.all
    respond_to do |format|
      format.json { render 'index' }
    end
  end
  
  def edit
    @variant = Variant.find(params[:variant_id])
    
  end
  
  def update
    @variant = Variant.find(params[:variant_id])
    
    @variant.update_attributes(variant_attributes)
    
    redirect_to edit_product_path :id => params[:product_id]
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variant = Variant.find(params[:variant_id])
    
    if @variant.destroy
      redirect_to edit_product_path :id => params[:product_id]
    end
  end
  
  def generate_product_variants
    respond_to do |format|
      format.json do
        params[:variants].each do |variant|
          @variant = Variant.new(product_id: params[:product_id])
          variant[1].each do |option_value| 
            @option_value = OptionValue.find_by(value: option_value)
            @variant.option_values << @option_value
          end
          @variant.save
        end
        
        redirect_to :back#edit_product_path(params[:product_id])
        
      end
    end
  end
  
  private
  
    def variant_attributes
      params.require(:variant).permit(:price, :sku)
    end

end
