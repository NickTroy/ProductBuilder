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
    @product_options = []
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
          @product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "product", :key => "key", :value => "value", :value_type => "string"))
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
    
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params)
          redirect_to products_url(:protocol => 'https')
        end
      end
    end
  end

  
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: params[:id])
    @variants = Variant.where(product_id: params[:id])
    
    @product_options = Option.where(product_id: params[:id])
    @images.each { |img| img.destroy }
    @variants.each do |var|  
      @pseudo_product = ShopifyAPI::Product.find(var.pseudo_product_id)
      @pseudo_product.destroy
      var.destroy
    end
    @options.each { |opt| opt.destroy } unless @options.nil?
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url(:protocol => 'https'), notice: 'Product was successfully deleted.' }
    end
    
  end

  

  def import
    @product_spreadsheet = Roo::Excelx.new(params[:file].path).sheet(0)
    @last_column = @product_spreadsheet.last_column
    @number_of_variants = @product_spreadsheet.column(@last_column).compact.count - 3
    @product_row = @product_spreadsheet.row(6)
    puts @product_row
    @product_title = @product_row[2]
    @product_details = @product_row[3]
    @product_vendor = @product_row[4]
    @product = ShopifyAPI::Product.new({
      :title => @product_title,
      :body_html => @product_details,
      :vendor => @product_vendor
    })
    @product.attributes[:tags] = "product"
    @product.save
    @product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "product", :key => "key", :value => "value", :value_type => "string"))
    
    Option.all.each do |option|
      option.products_options.create(:product_id => @product.id)
    end
    1.upto(@number_of_variants) do |i|
      @variant_row = @product_spreadsheet.row(5 + i)
      @variant = Variant.new(:product_id => @product.id)
      @pseudo_product_title = ""
      if @variant_row[9].nil?
        @upholstery = OptionValue.where(:value => @variant_row[10].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Upholstery')[0].id, :value => @variant_row[10].capitalize)
        @variant.option_values << @upholstery
        @pseudo_product_title += " #{@upholstery.option.name} : #{@upholstery.value}"
      else 
        @upholstery = OptionValue.where(:value => @variant_row[9].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Upholstery')[0].id, :value => @variant_row[9].capitalize)
        @variant.option_values << @upholstery
        @pseudo_product_title += " #{@upholstery.option.name} : #{@upholstery.value}"
      end
      @room = OptionValue.where(:value => @variant_row[11].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Room')[0].id, :value => @variant_row[11].capitalize)
      @variant.option_values << @room
      @pseudo_product_title += " #{@room.option.name} : #{@room.value}"
      @height = OptionValue.where(:value => @variant_row[13].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Height')[0].id, :value => @variant_row[13].capitalize)
      @variant.option_values << @height
      @pseudo_product_title += " #{@height.option.name} : #{@height.value}"
      @depth = OptionValue.where(:value => @variant_row[15].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Depth')[0].id, :value => @variant_row[15].capitalize)
      @variant.option_values << @depth
      @pseudo_product_title += " #{@depth.option.name} : #{@depth.value}"
      @width = OptionValue.where(:value => @variant_row[17].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Width')[0].id, :value => @variant_row[17].capitalize)
      @variant.option_values << @width
      @pseudo_product_title += " #{@width.option.name} : #{@width.value}"
      if @variant_row[19].nil?
        @type = OptionValue.where(:value => @variant_row[20].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Type')[0].id, :value => @variant_row[20].capitalize)
        @variant.option_values << @type
        @pseudo_product_title += " #{@type.option.name} : #{@type.value}"
      else 
        @type = OptionValue.where(:value => @variant_row[19].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Type')[0].id, :value => @variant_row[19].capitalize)
        @variant.option_values << @type
        @pseudo_product_title += " #{@type.option.name} : #{@type.value}"
      end
      if @variant_row[22].nil?
        @color = OptionValue.where(:value => @variant_row[23].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Color')[0].id, :value => @variant_row[23].capitalize)
        @variant.option_values << @color
        @pseudo_product_title += " #{@color.option.name} : #{@color.value}"
      else 
        @color = OptionValue.where(:value => @variant_row[22].capitalize)[0] || OptionValue.new(:option_id => Option.where(:name => 'Color')[0].id, :value => @variant_row[22].capitalize)
        @variant.option_values << @color
        @pseudo_product_title += " #{@color.option.name} : #{@color.value}"
      end
      
      @variant.save
      @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
      @pseudo_product_variant = @pseudo_product.variants.first
      @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
      @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                                 :pseudo_product_variant_id => @pseudo_product_variant.id)
      @pseudo_product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "variant", :key => "variant_id", :value => "#{@variant.id}", :value_type => "integer"))
    end
    redirect_to root_url(:protocol => 'https'), notice: "Product imported."
    @product_spreadsheet.close
  end



  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
end
