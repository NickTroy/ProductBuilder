class ProductsController < AuthenticatedController
  require 'roo'
  require 'csv'
  
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
    #ShopifyAPI::Product.all(:limit => 250).each_with_index do |p, i|
      #sleep 3 if i % 10 == 0
     # if p.tags == "product" #p.metafields[0].namespace == "product"  
      #  @all_products.push(p)    
      #end  
    #end
    #@products = ShopifyAPI::Product.find(:all)
    @products = Kaminari.paginate_array(@all_products, total_count: @all_products.count).page(params[:page]).per(10)
    @variants = Variant.all
    @images = ProductImage.all
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
    #@product_options = Option.joins("inner join products_options on products_options.product_id = #{params[:id]}").uniq
    @variants = Variant.where(product_id: @product.id)
    #respond_to do |format|
     # format.json { render 'show.json.jbuilder' }
    #end
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
          #@product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "product", :key => "key", :value => "value", :value_type => "string"))
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
      @pseudo_product = ShopifyAPI::Product.find(var.pseudo_product_id)
      @pseudo_product.destroy
      var.destroy
    end
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url(:protocol => 'https'), notice: 'Product was successfully deleted.' }
    end
    
  end

  

  def import
    @import_file = Roo::Excel.new(params[:file].path)
    @import_file.sheets.each_with_index do |sheet, index|
      #@product_spreadsheet = Roo::Excelx.new(params[:file].path).sheet(0)
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
        binding.pry
        @variant.save
        @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
        @pseudo_product_variant = @pseudo_product.variants.first
        @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
        @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                 :pseudo_product_variant_id => @pseudo_product_variant.id)
        @pseudo_product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "variant", :key => "variant_id", :value => "#{@variant.id}", :value_type => "integer"))
      end
    end
    @import_file.close
    redirect_to root_url(:protocol => 'https'), notice: "Product imported."
    
  end



  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
end
