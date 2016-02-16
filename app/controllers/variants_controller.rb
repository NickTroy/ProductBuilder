class VariantsController < AuthenticatedController

  def index
    @variants = Variant.all
    respond_to do |format|
      format.json { render 'index' }
    end
  end
  
  
  def edit
    @variant = Variant.find(params[:variant_id])
    @shopify_variant = ShopifyAPI::Variant.find(@variant.pseudo_product_variant_id)
    @image = @variant.product_image
    @product_images = ProductImage.where(product_id: @variant.product_id)
    @variant_images = @variant.variant_images
    @three_sixty_image_url = ""
    @three_sixty_image = @variant.three_sixty_image
    unless @three_sixty_image.nil?
      unless @three_sixty_image.plane_images.empty?      
        @first_plane_image = @three_sixty_image.plane_images.first.image.url
        @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
        @three_sixty_image_url.insert(4,'s')
        @images_path = @three_sixty_image_url.split('/')
        @images_path.delete_at(-1)
        @images_path = @images_path.join('/') 
        @images_names = []
        @three_sixty_image.plane_images.each do |plane_image|
          @images_names.push(plane_image.image.original_filename)
        end
        @images_names = @images_names.join(',')
      end
    end

  end
  
  def show
    @variants = Variant.where(product_id: params[:product_id])
  end
  
  def update
    if params[:commit] == 'Cancel'
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      return true
    end
    
    @variant = Variant.find(params[:variant_id])
    unless params[:image_id].nil? 
      @image_selected = VariantImage.find(params[:image_id])
      @variant.main_image_id = params[:image_id]
      @variant.save
    end
    @variant.update_attributes(variant_attributes)
    @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
    @pseudo_product_variant = @pseudo_product.variants.first
    @inventory_management = params[:inventory_management] == "shopify" ? "shopify" : nil
    @pseudo_product_variant.update_attributes(:price => variant_attributes[:price], :sku => variant_attributes[:sku], :inventory_management => @inventory_management)
    unless params[:inventory_management].nil?
      @pseudo_product_variant.update_attributes(:inventory_quantity => params[:inventory_quantity].to_i)
    end
    unless params[:image_id].nil? 
      @pseudo_product_image = @pseudo_product.images.first
      unless @pseudo_product_image.nil?
        @pseudo_product_image.destroy
      end
      @pseudo_product_image = ShopifyAPI::Image.new(:product_id => @pseudo_product.id)
      @pseudo_product_image.src = URI.join(request.url, @image_selected.image.url).to_s
      @pseudo_product_image.save
    end
    redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variant = Variant.find(params[:variant_id])
    @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
    @pseudo_product.destroy
    if @variant.destroy
      redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
    end
  end
  
  def generate_product_variants
    respond_to do |format|
      format.json do
        @product = ShopifyAPI::Product.find(params[:product_id])
        @product_details = @product.details
        params[:variants].each_with_index do |variant,index|
          
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
          sleep 1 if index > 10
        end
        
        redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      end
    end
  end
  
  def delete_all_variants
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variants = Variant.where(product_id: @product.id)
    @variants.each_with_index do |variant, index|
      @pseudo_product = ShopifyAPI::Product.find(variant.pseudo_product_id)
      variant.destroy
      @pseudo_product.destroy
      sleep 1 if index > 10
    end
    redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
  end
  
  private
  
    def variant_attributes
      params.require(:variant).permit(:price, :sku)
    end

end
