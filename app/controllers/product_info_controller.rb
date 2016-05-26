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
    @variants = Variant.where(product_id: params[:id])
    if @variants.length == 0 
      render json: { message: "No variants found" }, :status => 200
      return true
    end
    @main_variant = Variant.where(product_id: params[:id], main_variant: true)[0] unless Variant.where(product_id: params[:id], main_variant: true)[0].nil?
    @main_variant ||= Variant.where(product_id: params[:id]).first
    @main_variant_id = @main_variant.id
    #@main_variant_id = Variant.where(product_id: params[:id], main_variant: true)[0].id unless Variant.where(product_id: params[:id], main_variant: true)[0].nil?
    #@main_variant_id ||= Variant.where(product_id: params[:id]).first.id    
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
    product_option_values = OptionValue.joins("left join variants_option_values on option_values.id=variants_option_values.option_value_id inner join variants on variants.id=variants_option_values.variant_id and variants.product_id=#{params[:id]}").distinct
    product_option_values.each do |option_value|
      product_option = @product_options.find { |option| option[:option_name] == option_value.option.name }
      product_option[:option_values].push(option_value.value).uniq!
    end
    @product_options.sort_by! { |option| option[:order_number] }
    @first_image = ProductImage.where(product_id: params[:id]).first
    @option_dependency = []
    @options_count = @product_options.count
    
    query_for_variant_branches = "select " 
    @product_options.each_with_index do |option, index|
      option_query_row = "(select ov#{index}.value as v#{index} from option_values ov#{index}, variants_option_values vov#{index} where vov#{index}.variant_id = v.id and vov#{index}.option_value_id = ov#{index}.id and ov#{index}.option_id = #{option[:option_id]}), "
      query_for_variant_branches += option_query_row
    end
    query_for_variant_branches.chop!.chop!
    query_for_variant_branches_with_variant_ids = query_for_variant_branches + ", v.id from variants v where v.product_id = #{params[:id]}"
    query_for_variant_branches += "from variants v where v.product_id = #{params[:id]}"
    @variants_option_values = ActiveRecord::Base.connection.execute(query_for_variant_branches_with_variant_ids)
    build_option_dependency_tree
    respond_to do |format|
      format.json #{ render status: :ok, :callback => params[:callback] }
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
    @variants_option_values.each do |variant_option_values|#@variants.each do |variant|
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
