class ProductsController < AuthenticatedController
  require 'roo'
  require 'csv'
  require 'spreadsheet'
  
  def index
    @all_products = []
    @product_count = ShopifyAPI::Product.count
    @num_of_pages = (@product_count / 250.0).ceil
    1.upto(@num_of_pages) do |page|
      products = ShopifyAPI::Product.find( :all, :params => { :limit => 250, :page => page } )
      products.each do |product|
        if product.tags == "product" #p.metafields[0].namespace == "product"  
          @all_products.push(product)    
        end  
      end
    end
    @products = Kaminari.paginate_array(@all_products, total_count: @all_products.count).page(params[:page]).per(10)
    @variants = Variant.all
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: @product.id)
    @options = Option.all
    @option_groups = OptionGroup.all
    @product_options = []
    @collections = ShopifyAPI::CustomCollection.all
    @product_collections = @product.collections
    ProductsOption.where(:product_id => @product.id).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    #Option.joins("inner join products_options on products_options.product_id = #{params[:id]}").uniq
    @variants = Variant.where(product_id: @product.id)
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
    
    @product = ShopifyAPI::Product.find(params[:id])
    @collect = ShopifyAPI::Collect.new(:product_id => @product.id, :collection_id => params[:collection_id])
    @collect.save
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params)
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
    @images = ProductImage.where(product_id: params[:id])
    @variants = Variant.where(product_id: params[:id])
    
    @images.each { |img| img.destroy }
    @variants.each do |var|  
      begin
        @pseudo_product = ShopifyAPI::Product.find(var.pseudo_product_id)
      rescue
        var.destroy
      else
        @pseudo_product.destroy
        var.destroy
      end
    end
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
      
      @product = ShopifyAPI::Product.new({
        :title => @product_title,
        :body_html => @product_details,
        :vendor => @product_vendor
      })
      @product.attributes[:tags] = "product"
      @product.save
      @product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "product", :key => "key", :value => "value", :value_type => "string"))
     
      1.upto(@number_of_variants) do |i|
        @variant_row = @import_file.sheet(index).row(5 + i)
        @variant = Variant.new(:product_id => @product.id)
        @pseudo_product_title = ""
        @first_option_column.upto(@first_option_column + @options_count - 1) do |j|
          @option_name = @options_row[j]
          @option = Option.where(name: @option_name)[0] || Option.create(name: @option_name)
          if @option.products_options.where(:product_id => @product.id).empty?
            @option.products_options.create(:product_id => @product.id)
          end
          @option_value = OptionValue.where(:value => @variant_row[j].capitalize)[0] || OptionValue.create(:option_id => @option.id, :value => @variant_row[j].capitalize)
          @variant.option_values << @option_value
          @pseudo_product_title += " #{@option.name} : #{@option_value.value}"
    
        end
        

        @variant.sku = @variant_row[@sku_column]     
        @variant.length = @variant_row[@length_column].to_s unless @variant_row[@length_column].nil?
        @variant.height = @variant_row[@height_column].to_s unless @variant_row[@height_column].nil? 
        @variant.depth = @variant_row[@depth_column].to_s unless @variant_row[@depth_column].nil?
        @variant.price = @variant_row[@price_column].to_s unless @variant_row[@price_column].nil?
        @variant.save
        unless @variant_images_column.nil? 
          variant_images_links = @variant_row[@variant_images_column].split(',') unless @variant_row[@variant_images_column].nil?
          unless variant_images_links.nil?
            variant_images_links.each do |image_link|
              @variant_image = VariantImage.new(:variant_id => @variant.id)
              @variant_image.image_from_url(image_link)
              @variant_image.save
              binding.pry
            end
          end
        end

        @variant.save
        @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
        @pseudo_product_variant = @pseudo_product.variants.first
        @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title, :price => @variant.price, :sku => @variant.sku)
        @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                 :pseudo_product_variant_id => @pseudo_product_variant.id)
        @pseudo_product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "variant", :key => "variant_id", :value => "#{@variant.id}", :value_type => "integer"))
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
        variant.variant_images.each do |variant_image|
          images_links.push URI.join(request.url, variant_image.image.url).to_s
        end
        variant_row[variant_images_column] = images_links.join(',')
      end
    end
    book.write './public/assets/export.xls'
    render json: { message: "success" }, :status => 200 
  end



  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
end
