class ProductsController < AuthenticatedController
  include ProductsHelper
  
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
    @color_ranges = ColorRange.all
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

  def search
    @three_sixty_images = ThreeSixtyImage.order('title ASC').where "title like '%#{ params[:search] }%'"
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
    parse_import_file params[:file].path
    redirect_to root_url(:protocol => 'https'), notice: "Product imported."
  end
  
  def export
    create_export_file
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
      params.permit(:body_html, :handle, :options, :template_suffix, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor, :search)
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
