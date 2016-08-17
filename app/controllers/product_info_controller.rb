class ProductInfoController < ApplicationController
  
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end

  def show
    @default_captions = DefaultCaption.all
    @variants = Variant.where(product_id: params[:id], state: true)
    @product_info = ProductInfo.find_by(main_product_id: params[:id])
    @shipping_method = @product_info.shipping_method unless @product_info.nil?
    if @variants.length == 0 
      render json: { message: "No variants found" }, :status => 200
      return true
    end
    @main_variant = Variant.where(product_id: params[:id], main_variant: true, state: true)[0] unless Variant.where(product_id: params[:id], main_variant: true, state: true)[0].nil?
    @main_variant ||= Variant.where(product_id: params[:id], state: true).first
    color_option_id = Option.find_by(name: "Color").id
    color_option_value = @main_variant.option_values.where(option_id: color_option_id)[0]
    if color_option_value.nil?
      @main_variant_color_range = ""
    else
      if color_option_value.color_range.nil?
        @main_variant_color_range = ""
      else
        @main_variant_color_range = color_option_value.color_range.name
      end
    end
    @main_variant_id = @main_variant.id
    @product_options = []
    Option.all.each do |option|
      if option.products_options.where(:product_id => params[:id]).any?
        @product_options.push({ :option_name => option.name, :order_number => option.order_number, :option_values => [], :option_id => option.id })
      end
    end
    @sketch_front_image = ProductImage.where(:product_id => params[:id])[0]
    @sketch_back_image = ProductImage.where(:product_id => params[:id])[1]
    @slider_images_params = SliderImagesParam.all
    @product_option_groups = []
    @option_groups = OptionGroup.all
    @option_groups.each do |option_group|
      @include_option_group = false
      option_group.options.each do |option|
        unless @product_options.find { |product_option| product_option[:option_name] == option.name }.nil?
          @include_option_group = true
        end 
      end
      @product_option_groups.push(option_group) if @include_option_group
    end
    # remove upholstery option values from all option values due to front end logic changes
    upholstery_option_values = Option.find_by(name: "Upholstery").option_values
    product_option_values = OptionValue.joins("left join variants_option_values on option_values.id=variants_option_values.option_value_id inner join variants on variants.id=variants_option_values.variant_id and variants.product_id=#{params[:id]}").distinct - upholstery_option_values
    product_option_values.each do |option_value|
      product_option = @product_options.find { |option| option[:option_name] == option_value.option.name }
      product_option[:option_values].push(option_value.value).uniq!
    end
    @product_options.sort_by! { |option| option[:order_number] }
    option_values_with_color_ranges = OptionValue.joins("left join variants_option_values on option_values.id=variants_option_values.option_value_id inner join variants on variants.id=variants_option_values.variant_id and variants.product_id=#{params[:id]}")
                               .distinct.where(option_id: color_option_id)
                               .joins("join color_ranges on color_ranges.id = option_values.color_range_id ")
                               .select("color_ranges.name as color_range_name, option_values.value as value, color_ranges.color as color")
    @color_ranges = []       
    
    option_values_with_color_ranges.each do |option_value|
      color_range_name = option_value.color_range_name
      color_range = @color_ranges.find { |col_range| col_range[:name] == color_range_name }
      if color_range.nil?
        color_range = { name: color_range_name, option_values: [], color: option_value.color }
        @color_ranges.push(color_range)
      end
      color_range[:option_values].push(option_value.value)
    end
    
    @first_image = ProductImage.where(product_id: params[:id]).first
    @option_dependency = []
    @options_count = @product_options.count
    @variants_option_values = @variants.map do |variant|
      crap = Array.new
      @product_options.map { |product_option| crap << OptionValue.where(:option_id => product_option[:option_id]).includes( :variants ).where( :variants => { id: variant.id} ).first.value }
      crap << variant.id
    end
    @color_and_material_values = @variants_option_values.to_a.map { |branch| [branch[-3], branch[-2]] }.uniq

    build_option_dependency_tree
    respond_to do |format|
      format.json 
    end
  end  
  
  def handle
    @variant = Variant.find_by(:pseudo_product_id => params[:product_id])
    selected_option_values = []
    @variant.option_values.each do |option_value|
      selected_option_values.push({ :option_name => option_value.option.name, :option_value => option_value.value, :option_order_number => option_value.option.order_number})
    end
    @product_info = ProductInfo.find_by(:main_product_id => @variant.product_id)
    render :json => { :handle => @product_info.handle, :selected_option_values => selected_option_values }
  end

  private

  def build_option_dependency_tree
    @variants_option_values.each do |variant_option_values|
      @variant_branch = []
      variant_option_values.reverse.each do |option_value|
        @variant_branch = [option_value, @variant_branch]
      end
      if @option_dependency.empty?
        @option_dependency = @variant_branch
      else
        update_option_dependency
      end
    end
  end

  def update_option_dependency(option_order_number = 1, option_dependency = @option_dependency, variant_branch = @variant_branch)
    option_value = variant_branch[0] 
    index_update = option_dependency.find_index(option_value)
    unless index_update
      option_dependency.push option_value
      option_dependency.push variant_branch[1]
      return
    end
    option_dependency = option_dependency[index_update + 1]
    variant_branch = variant_branch[1]
    update_option_dependency(option_order_number + 1, option_dependency, variant_branch)
  end
end
