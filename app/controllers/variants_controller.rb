class VariantsController < AuthenticatedController

  def index
    @variants = Variant.all
    respond_to do |format|
      format.json { render 'index' }
    end
  end
  
  
  def edit
    @variant = Variant.find(params[:variant_id])
    @image = @variant.product_image
    @images = ProductImage.where(product_id: @variant.product_id)
  end
  
  def show
    @variants = Variant.where(product_id: params[:product_id])
  end
  
  def update
    if params[:commit] == 'Cancel'
      redirect_to edit_product_path :id => params[:product_id]
      return true
    end
    
    @variant = Variant.find(params[:variant_id])
    unless params[:image_id].nil? 
      @image_selected = ProductImage.find(params[:image_id])
      @variant.product_image = @image_selected
    end
    @variant.update_attributes(variant_attributes)
    
    @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
    @pseudo_product_variant = @pseudo_product.variants.first
    @pseudo_product_variant.update_attributes(price: variant_attributes[:price], sku: variant_attributes[:sku] )
    unless params[:image_id].nil? 
      @pseudo_product_image = @pseudo_product.images.first || ShopifyAPI::Image.new(:product_id => @pseudo_product.id)
      @pseudo_product_image.src = URI.join(request.url, @image_selected.image.url).to_s
      @pseudo_product_image.save
    end
    redirect_to edit_product_path :id => params[:product_id]
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variant = Variant.find(params[:variant_id])
    @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
    @pseudo_product.destroy
    if @variant.destroy
      redirect_to edit_product_path :id => params[:product_id]
    end
  end
  
  def generate_product_variants
    respond_to do |format|
      format.json do
        params[:variants].each do |variant|
          
          @variant = Variant.new(product_id: params[:product_id])
          @pseudo_product_title = ""
          variant[1].each do |option_value|
            @option_value = OptionValue.find_by(value: option_value)
            @variant.option_values << @option_value
            @pseudo_product_title += " #{@option_value.option.name} : #{@option_value.value}"
          end
          @variant.save
          @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
          @pseudo_product_variant = @pseudo_product.variants.first
          @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
          @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                     :pseudo_product_variant_id => @pseudo_product_variant.id)
          @pseudo_product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "variant", :key => "variant_id", :value => "#{@variant.id}", :value_type => "integer"))
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
