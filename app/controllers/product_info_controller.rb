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
    @main_variant_id = @variants.first.id
    @product_options = []
    #ProductsOption.where(:product_id => params[:id]).each do |product_option|
      #@product_options.push(Option.where(id: product_option.option_id)[0])
    #end
    Option.all.each do |option|
      if option.products_options.where(:product_id => params[:id]).any?
        @product_options.push({ :option_name => option.name, :order_number => option.order_number, :option_values => [] })
      end
    end
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
    @variants.each do |variant|
      variant.option_values.each do |option_value|
        @product_options.each do |option|
          if option[:option_name].downcase == option_value.option.name.downcase
            option[:option_values].push(option_value.value).uniq!
          end
        end
      end
    end
    #@product_options = Option.joins("inner join products_options on products_options.option_id = options.id").uniq
    @product_options.sort_by! { |option| option[:order_number] }
    @first_image = ProductImage.where(product_id: params[:id]).first
    @option_dependency = []
    @options_count = @product_options.count
    build_option_dependency_tree
    respond_to do |format|
      format.json { render status: :ok, :callback => params[:callback] }
    end
    
  end  

  private

  def build_option_dependency_tree
    @variants.each do |variant|
      @variant_branch = []
      @variant_option_values = []
      variant.option_values.each do |option_value|
        @variant_option_values.push option_value.value
      end
      @variant_option_values.sort_by! { |opt_val| OptionValue.where(:value => opt_val)[0].option.order_number }
      @variant_option_values.reverse.each do |option_value|
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
