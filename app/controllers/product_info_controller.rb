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
    @product_options = []
    #ProductsOption.where(:product_id => params[:id]).each do |product_option|
      #@product_options.push(Option.where(id: product_option.option_id)[0])
    #end
    Option.all.each do |option|
      @product_options.push({ :option_name => option.name, :order_number => option.order_number, :option_values => [] })
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
    @variants.each do |variant|
      @option_value_ordered = []
      variant.option_values.each do |option_value| 
        @option_value_ordered.push( option_value.value )
      end
      @option_value_ordered.sort_by! do |option_value|
        OptionValue.where(:value => option_value)[0].option.order_number
      end
      @variant_branch = []
      puts @option_value_ordered.length - 1
      1.upto(@option_value_ordered.length - 1) do |i|
        @variant_branch.push({ @option_value_ordered[i-1].to_sym => @option_value_ordered[i] })
      end
      @option_dependency |= @variant_branch
    end
    #1.upto(@product_options.length - 1) do |i|
      #@product_options[i-1].option_values.each do |current_option_value|
        #@product_options[i].option_values.each do |next_option_value|   
          #@variants.each do |variant|
            #if variant.option_values.include?(current_option_value) and variant.option_values.include?(next_option_value)
              #@option_dependency[current_option_value.value] = next_option_value.value
            #end
          #end
        #end
      #end
    #end
    respond_to do |format|
      format.json { render status: :ok, :callback => params[:callback] }
    end
    
  end  
end
