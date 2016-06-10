class ProductsController < AuthenticatedController
  require 'roo'
  require 'csv'
  require 'spreadsheet'
  
  def index
    @product_builder_collection = ShopifyAPI::SmartCollection.where(:title => "Product_builder_products")[0]
    @all_products = ShopifyAPI::Product.find(:all, :params => { :limit => 250, :collection_id => @product_builder_collection.id})
    @products = Kaminari.paginate_array(@all_products, total_count: @all_products.count).page(params[:page]).per(10)
    @variants = Variant.all
    @slider_images_params = SliderImagesParam.all
    @three_sixty_images = ThreeSixtyImage.order('title ASC')
    @shipping_methods = ShippingMethod.all
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
    @product_info = ProductInfo.find_by(main_product_id: @product.id) || ProductInfo.create(:main_product_id => @product.id)
    @images = ProductImage.where(product_id: @product.id)
    @three_sixty_images = ThreeSixtyImage.order('title ASC')
    @shipping_methods = ShippingMethod.all
    @main_variant = Variant.where(:product_id => @product.id, :main_variant => true)[0]
    @main_variant_present = Variant.where(:product_id => @product.id, :main_variant => true).length == 1
    @options = Option.all
    @option_groups = OptionGroup.all
    @product_options = []
    @collections = ShopifyAPI::CustomCollection.all
    @product_collections = @product.collections
    ProductsOption.where(:product_id => @product.id).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    variant_option_values_query = "select distinct option_values.id, option_values.value, options.name from options " +
                                  "inner join option_values on options.id = option_values.option_id " + 
                                  "inner join variants_option_values on variants_option_values.option_value_id = option_values.id " +
                                  "inner join variants on variants.id=variants_option_values.variant_id and variants.product_id = #{@product.id};"
    @variant_option_values = ActiveRecord::Base.connection.execute(variant_option_values_query).to_a
    @options_with_values = {}
    @product_options.each do |option|
      option_values = @variant_option_values.select { |option_value| option_value[2] == option.name}
      @options_with_values[option.name] = option_values.map { |option_value| [option_value[0], option_value[1]] }
    end
    if filtering_params.nil?
      @variants = Variant.where(product_id: @product.id)
    else
      option_values_ids = filtering_params[:search_option_values_ids]
      if option_values_ids.nil? or option_values_ids.empty? or option_values_ids == "[]"
        @variants = Variant.where(product_id: @product.id)
      else
        option_values_ids = option_values_ids.split(',').map(&:to_i)
        @variants = Variant.joins("inner join variants_option_values vov1 on vov1.option_value_id=#{option_values_ids.shift} and variants.id = vov1.variant_id ").where(:product_id => @product.id)
        option_values_ids.each_with_index do |option_value_id, index|
          @variants = @variants.joins("inner join variants_option_values vov#{index + 2} on vov#{index + 2}.option_value_id=#{option_value_id} and variants.id = vov#{index + 2}.variant_id ")
        end
      end
      @per_page = filtering_params[:per_page]
    end
    
    @variants = @variants.filter(params[:filtering_params].slice(:sku_like)) if params[:filtering_params]
    @variants_count = @variants.count
    case @per_page
    when ""
      @per_page = 25
    when nil
      @per_page = 25
    when "-1"
      @per_page = @variants.count
    else
      @per_page = @per_page.to_i
    end
    @variants = Kaminari.paginate_array(@variants, total_count: @variants.count).page(params[:page]).per(@per_page)
  end
  
  def show
    @product = ShopifyAPI::Product.find(params[:id])
    @product_options = []
    ProductsOption.where(:product_id => @product.id).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    @variants = Variant.where(product_id: @product.id)
  end
  
  def create
    
    if params[:commit] == 'Back to all products'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    
    @product = ShopifyAPI::Product.new(product_params)   
    
    @product.attributes[:tags] = "product"
    respond_to do |format|
      format.html do 
        if @product.save
          @product_info = ProductInfo.create(:handle => @product.handle, :main_product_id => @product.id)
          redirect_to edit_product_url(:id => @product.id, :protocol => 'https')
        end
      end
    end
  end
  
  def update
    
    if params[:commit] == 'Back to all products'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    
    if params[:search] == 'Search'
      redirect_to edit_product_url(:protocol => 'https', :id => params[:id], :filtering_params => {:search_option_values_ids => params[:search_option_values_ids], :sku_like => params[:sku_like], :per_page => params[:per_page]})
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:id])
    @product_info = ProductInfo.find_by(:main_product_id => @product.id) || ProductInfo.create(:main_product_id => @product.id)
    @product_info.update_attributes(product_info_params)
    shipping_method_id = params[:shipping_method_id]
    unless shipping_method_id == "0" or shipping_method_id == nil or shipping_method_id == ""
      @shipping_method = ShippingMethod.find(shipping_method_id)
      @shipping_method.product_infos << @product_info
    end
    @collect = ShopifyAPI::Collect.new(:product_id => @product.id, :collection_id => params[:collection_id])
    @collect.save
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params)
          @product_info.update_attributes(:handle => @product.handle)
          @product_details = @product.body_html
          unless @product_details.nil?
            Variant.where(:product_id => @product.id).each do |variant|
              variant.update_attributes(:product_details => @product_details)
            end
          end
          redirect_to products_url(:protocol => 'https')
        end
      end
    end
  end

  
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    @product_info = ProductInfo.find_by(:main_product_id => @product.id)
    @images = ProductImage.where(product_id: params[:id])
    @variants = Variant.where(product_id: params[:id])
    
    @images.each { |img| img.destroy }
    @variants.each do |var|  
      begin
        sleep 1
        @pseudo_product = ShopifyAPI::Product.find(var.pseudo_product_id)
      rescue
        var.destroy
      else
        @pseudo_product.destroy
        var.destroy
      end
    end
    @product_info.destroy unless @product_info.nil?
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url(:protocol => 'https'), notice: 'Product was successfully deleted.' }
    end
    
  end

  

  def import
    @import_file = Roo::Excel.new(params[:file].path)
    @import_file.sheets.each_with_index do |sheet, index|
      @last_column = @import_file.sheet(index).last_column
      @number_of_variants = @import_file.sheet(index).column(@last_column).compact.count - 2
      @product_row = @import_file.sheet(index).row(6)
      @product_title = @product_row[2]
      @product_details = @product_row[3]
      @product_vendor = @product_row[4]
      
      @options_row = @import_file.sheet(index).row(2)
      @options_count = 0
      @import_file.sheet(index).row(1).each_with_index do |cell, ind|
        unless cell.nil?
          if cell.include? "Option"
            @options_count += 1
            @first_option_column ||= ind
          end
          if cell.include? "Variant ITEM #"
            @sku_column = ind
          end
          if cell.include? "Variant length"
            @length_column = ind
          end
          if cell.include? "Variant height"
            @height_column = ind
          end
          if cell.include? "Variant depth"
            @depth_column = ind
          end
          if cell.include? "Variant price"
            @price_column = ind
          end
          if cell.include? "Variant Images"
            @variant_images_column = ind
          end
        end
      end
      
      @product = ShopifyAPI::SmartCollection.where(title:"Product_builder_products")[0].products.find { |product| product.title == @product_title }
      if @product.nil?
        @product = ShopifyAPI::Product.new({
          :title => @product_title,
          :body_html => @product_details,
          :vendor => @product_vendor
        })
      
        @product.attributes[:tags] = "product" unless @product.attributes[:tags] == "product"
        @product.save
      end
      @product_info = ProductInfo.create(:main_product_id => @product.id, :handle => @product.handle)
      1.upto(@number_of_variants) do |i|
        variant_updating = true
        @variant_row = @import_file.sheet(index).row(5 + i)
        @variant = Variant.where(:product_id => @product.id, :sku => @variant_row[@sku_column])[0]
        if @variant.nil?
          variant_updating = false
          @variant = Variant.new(:product_id => @product.id) 
          @pseudo_product_title = ""
          @first_option_column.upto(@first_option_column + @options_count - 1) do |j|
            @option_name = @options_row[j]
            @option = Option.where(name: @option_name)[0] || Option.create(name: @option_name)
            if @option.products_options.where(:product_id => @product.id).empty?
              @option.products_options.create(:product_id => @product.id)
            end
            @option_value = @option.option_values.where(:value => @variant_row[j].capitalize)[0] || OptionValue.create(:option_id => @option.id, :value => @variant_row[j].capitalize)
            @variant.option_values << @option_value
          end
        end
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

        @variant.sku = @variant_row[@sku_column]     
        @variant.length = @variant_row[@length_column].to_s unless @variant_row[@length_column].nil?
        @variant.height = @variant_row[@height_column].to_s unless @variant_row[@height_column].nil? 
        @variant.depth = @variant_row[@depth_column].to_s unless @variant_row[@depth_column].nil?
        @variant.price = @variant_row[@price_column].to_s unless @variant_row[@price_column].nil?
        @variant.save
        unless @variant_images_column.nil? or variant_updating
          variant_images_links = @variant_row[@variant_images_column].split(',') unless @variant_row[@variant_images_column].nil?
          unless variant_images_links.nil?
            @three_sixty_image = @variant.three_sixty_image
            if @three_sixty_image.nil?
              @three_sixty_image = ThreeSixtyImage.create(:title => @pseudo_product_title)
            end
            
            @three_sixty_image.variants << @variant
            variant_images_links.each do |image_link|
              @variant_image = VariantImage.new(:three_sixty_image_id => @three_sixty_image.id)
              @variant_image.image_from_url(image_link)
              @variant_image.save
            end
          end
        end

        @variant.save
        sleep 0.5
        @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
        @pseudo_product_variant = @pseudo_product.variants.first
        @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title, :price => @variant.price, :sku => @variant.sku)
        @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                 :pseudo_product_variant_id => @pseudo_product_variant.id)
      end
    end
    @import_file.close
    redirect_to root_url(:protocol => 'https'), notice: "Product imported."
    
  end
  
  def export
    
    book = Spreadsheet::Workbook.new

    @product_ids = params[:product_ids].split(',').map!(&:to_i)
    @product_ids.each_with_index do |product_id, index|
      @product = ShopifyAPI::Product.find(product_id)
      sheet = book.create_worksheet(:name => "product ##{index + 1}")
      title_row = sheet.row(0)
      description_row = sheet.row(1)
      product_row = sheet.row(5)
      title_row[0] = "Product Title"
      product_row[0] = @product.title
      title_row[1] = "URL - Handle"
      title_row[2] = "Product Title"
      product_row[2] = @product.title
      title_row[3] = "Product Details - Body (HTML)"
      product_row[3] = @product.body_html
      title_row[4] = "Brand - Vendor"
      product_row[4] = @product.vendor
      title_row[5] = "Type"
      title_row[6] = "Detail - Tags"
      title_row[7] = "Make Visible"

      
      @product_options = []
      ProductsOption.where(:product_id => product_id).each do |pr_opt|
        @product_options.push(Option.find(pr_opt.option_id))
      end
      options_index_offset = 8
      @product_options.sort! { |option1, option2| option1.order_number <=> option2.order_number }
      @product_options.each_with_index do |option, option_index|
        
        title_row[options_index_offset + option_index] = "Option #{option_index + 1}"
        description_row[options_index_offset + option_index] = option.name 
      end
      
      sku_column = @product_options.count + options_index_offset
      title_row[sku_column] = "Variant ITEM #"
      
      price_column = @product_options.count + options_index_offset + 1
      title_row[price_column] = "Variant price"
      description_row[price_column] = "price"
      variant_images_column = @product_options.count + options_index_offset + 2
      title_row[variant_images_column] = "Variant Images"
      
      length_column = @product_options.count + options_index_offset + 3
      title_row[length_column] = "Variant length"
      description_row[length_column] = "length"
      height_column = @product_options.count + options_index_offset + 4
      title_row[height_column] = "Variant height"
      description_row[height_column] = "height"
      depth_column = @product_options.count + options_index_offset + 5
      title_row[depth_column] = "Variant depth"
      description_row[depth_column] = "depth"
      
      
      @product_variants = Variant.where(:product_id => product_id)
      @product_variants.each_with_index do |variant, variant_index|
        variant_row_offset = 5
        variant_row = sheet.row(5 + variant_index)
        options_index_offset = 8
        variant.option_values.sort { |opt_val1, opt_val2| opt_val1.option.order_number <=> opt_val2.option.order_number }.each_with_index do |option_value, option_value_index|
          variant_row[options_index_offset + option_value_index] = option_value.value
          variant_row[sku_column] = variant.sku
          variant_row[length_column] = variant.length
          variant_row[height_column] = variant.height
          variant_row[depth_column] = variant.depth
          variant_row[price_column] = variant.price
        end
        images_links = []
        unless variant.three_sixty_image.nil?
          variant.three_sixty_image.variant_images.each do |variant_image|
            images_links.push URI.join(request.url, variant_image.image.url).to_s
          end
        end
        variant_row[variant_images_column] = images_links.join(',')
      end
    end
    book.write './public/assets/export.xls'
    render json: { message: "success" }, :status => 200 
  end
  
  def unassign_from_collection
    @collect =  ShopifyAPI::Collect.where(:product_id => params[:product_id], :collection_id => params[:collection_id])[0]
    if @collect.destroy
      render json: { message: "deleted" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
    
  end



  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
    def product_info_params
      params.permit(:why_we_love_this, :be_sure_to_note, :country_of_origin, :primary_materials, 
                    :requires_assembly, :care_instructions, :shipping_restrictions, :return_policy,
                    :lead_time, :lead_time_unit)
    end


  def filtering_params
    params[:filtering_params]
  end

end
