class VariantsController < AuthenticatedController

  def index
    @variants = Variant.all
    respond_to do |format|
      format.json { render 'index' }
    end
  end
  
  
  def edit
    @variant = Variant.find(params[:variant_id])
    begin
      @shopify_variant = ShopifyAPI::Variant.find(@variant.pseudo_product_variant_id)
    rescue
      recreate_pseudo_product
    ensure
      @shopify_variant = ShopifyAPI::Variant.find(@variant.pseudo_product_variant_id) if @shopify_variant.nil?
      @three_sixty_image_url = ""
      @three_sixty_images = ThreeSixtyImage.order('title ASC')
      @three_sixty_image = @variant.three_sixty_image
      unless @three_sixty_image.nil?
        @plane_images = @three_sixty_image.plane_images
        @variant_images = @three_sixty_image.variant_images
        unless @plane_images.empty?      
          @first_plane_image = @plane_images.first.azure_image.url
          @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
          @images_path = @three_sixty_image_url.split('/')
          @images_path.delete_at(-1)
          @images_path = @images_path.join('/') 
          @images_names = []
          @plane_images.each do |plane_image|
            @images_names.push(plane_image.azure_image.original_filename)
          end
          @images_names = @images_names.join(',')
        end
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
    respond_to do |format|
      format.html do
        unless params[:image_id].nil? 
          @image_selected = VariantImage.find(params[:image_id])
          @variant.main_image_id = params[:image_id]
          @variant.save
        end
      
        if variant_attributes[:main_variant]
          Variant.where(:main_variant => true, :product_id => @variant.product_id).each do |v|
            v.update_attributes(:main_variant => false) 
          end
        end
        
        @variant.update_attributes(variant_attributes)
        
        begin
          @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
        rescue
          recreate_pseudo_product
        ensure
          @product = ShopifyAPI::Product.find(@variant.product_id)
          @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id) if @pseudo_product.nil?
          
          @pseudo_product_title = "#{@product.title} "
          @color_option_value = @variant.option_values.find { |opt_val| opt_val.option.name == "Color"}
          @pseudo_product_title += @color_option_value.nil? ? "(" : "(#{@color_option_value.value} " 
          @upholstery_option_value = @variant.option_values.find { |opt_val| opt_val.option.name == "Upholstery"}
          @pseudo_product_title += @upholstery_option_value.nil? ? ")" : "#{@upholstery_option_value.value})"
          @variant_length = @variant.option_values.find { |opt_val| opt_val.option.name == "Lengths" }
          @variant_length = @variant_length.value unless @variant_length.nil?
          @variant_depth = @variant.option_values.find { |opt_val| opt_val.option.name == "Depth" }
          @variant_depth = @variant_depth.value unless @variant_depth.nil?
          @pseudo_product_title = "#{@variant_length} #{@variant_depth} #{@pseudo_product_title}"
          @pseudo_product.update_attributes(:title => @pseudo_product_title)
          
          @pseudo_product_variant = @pseudo_product.variants.first
          @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
          
          @inventory_management = params[:inventory_management] == "shopify" ? "shopify" : nil
          @pseudo_product_variant.update_attributes(:price => variant_attributes[:price], :sku => variant_attributes[:sku], :inventory_management => @inventory_management, :option1 => @pseudo_product_title)
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
      end
      format.json do 
        @variant.update_attributes(variant_attributes)
        render json: { message: "updated" }, status: 200
      end
    end
  end
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variant = Variant.find(params[:variant_id])
    begin 
      @pseudo_product = ShopifyAPI::Product.find(@variant.pseudo_product_id)
    rescue
      if @variant.destroy
        redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      end
    else
      @pseudo_product.destroy
      if @variant.destroy
        redirect_to edit_product_url(:protocol => 'https', :id => params[:product_id])
      end
    end
  end
  
  def generate_product_variants
    respond_to do |format|
      format.json do
        @product = ShopifyAPI::Product.find(params[:product_id])
        @product_details = @product.body_html
        params[:variants].each_with_index do |variant,index|
          
          @variant = Variant.new(product_id: params[:product_id], product_details: @product_details)
          @pseudo_product_title = "#{@product.title} "
          variant[1].each do |option_value|
            @option_value = OptionValue.find_by(value: option_value)
            @variant.option_values << @option_value
            #@pseudo_product_title += " #{@option_value.option.name} : #{@option_value.value}"
          end
          @color_option_value = @variant.option_values.find { |opt_val| opt_val.option.name == "Colors"}
          @pseudo_product_title += @color_option_value.nil? ? "(" : "(#{@color_option_value.value} " 
          @upholstery_option_value = @variant.option_values.find { |opt_val| opt_val.option.name == "Upholstery"}
          @pseudo_product_title += @upholstery_option_value.nil? ? ")" : "#{@upholstery_option_value.value})"
          
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
  
  def multiple_three_sixty_image_assignment
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    variants_ids = params[:variants_ids]
    variants_ids.each do |variant_id|
      @variant = Variant.find(variant_id)
      @three_sixty_image.variants << @variant
    end
    render json: { message: "assigned", title: @three_sixty_image.title }, status: 200
  end
  
  def delete_selected_variants
    variant_ids = params[:variant_ids]
    variant_ids.each do |variant_id|
      Variant.find(variant_id.to_i).destroy
    end
    render json: { message: "success"}, :status => 200 
  end
  
  def delete_all_variants
    @product = ShopifyAPI::Product.find(params[:product_id])
    @variants = Variant.where(product_id: @product.id)
    @variants.each_with_index do |variant, index|
      begin
        @pseudo_product = ShopifyAPI::Product.find(variant.pseudo_product_id)
      rescue
        variant.destroy
      else
        @pseudo_product.destroy
        variant.destroy
        sleep 1 if index > 10
      end
    end
    render json: { message: "success"}, :status => 200 
  end
  
  def turn_off_variants
    variants_ids = params[:variants_ids]
    variants_ids.each do |variant_id|
      variant = Variant.find(variant_id)
      variant.update_attributes(state: false)
    end
    
    render json: { message: "turned off"}, :status => 200 
  end
  
  def turn_on_variants
    variants_ids = params[:variants_ids]
    variants_ids.each do |variant_id|
      variant = Variant.find(variant_id)
      variant.update_attributes(state: true)
    end
  
    render json: { message: "turned on"}, :status => 200 
  end
  
  private
  
    def variant_attributes
      params.require(:variant).permit(:price, :sku, :length, :height, :depth, 
                                      :main_variant, :vendor_sku, :room, :care_instructions,
                                      :weight, :condition, :state)
    end
    
    def recreate_pseudo_product
      @pseudo_product_title = ""
      @variant.option_values.each do |option_value|
        @pseudo_product_title += " #{option_value.option.name} : #{option_value.value}"
      end
      @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
      @pseudo_product_variant = @pseudo_product.variants.first
      @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
      @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                 :pseudo_product_variant_id => @pseudo_product_variant.id)
    end

end
