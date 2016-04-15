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
    @main_variant_id = Variant.where(product_id: params[:id], main_variant: true)[0].id unless Variant.where(product_id: params[:id], main_variant: true)[0].nil?
    @main_variant_id ||= Variant.where(product_id: params[:id]).first.id    
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
    @variants_option_values = ActiveRecord::Base.connection.execute(query_for_variant_branches)
    build_option_dependency_tree
    
    @variants_option_values_and_ids = ActiveRecord::Base.connection.execute(query_for_variant_branches_with_variant_ids)
    @three_sixty_images_info = ActiveRecord::Base.connection.execute('select plane_images.image_file_name, three_sixty_images.id, three_sixty_images.clockwise, three_sixty_images.rotations_count, three_sixty_images.rotation_speed, variants.id from plane_images inner join three_sixty_images on plane_images.three_sixty_image_id = three_sixty_images.id inner join variants on three_sixty_images.variant_id = variants.id;').to_a
    @variant_images_info = ActiveRecord::Base.connection.execute('select vi.id, vi.image_file_name, v.id from variant_images vi inner join variants v;')
    @variants_option_values_and_ids.each_with_index do |variant_branch|
      variant_branch.each_with_index do |option_value, index|
        unless index == variant_branch.length - 1
          variant_branch[index] = [@product_options[index][:option_name], option_value]
        end
      end
    end
    @variants_info = []
    @variants.each do |variant|
      variant_option_values_branch = @variants_option_values_and_ids.find{ |branch| branch.last == variant.id }
      variant_info = { :variant_id => variant.id }
      variant_info[:pseudo_product_variant_id] = variant.pseudo_product_variant_id
      variant_info[:length] = variant.length
      variant_info[:depth] = variant.depth
      variant_info[:height] = variant.height
      variant_info[:price] = variant.price
      variant_info[:sku] = variant.sku
      variant_info[:options] = []
      variant_option_values_branch.each_with_index do |option_with_value, index|
        unless index == variant_option_values_branch.length - 1
          variant_info[:options].push(option_with_value)
        end
      end
      three_sixty_image_info = {}
      three_sixty_image_info_query = @three_sixty_images_info.select { |branch| branch.last == variant.id } unless @three_sixty_images_info.nil?
      unless three_sixty_image_info_query.empty?
        three_sixty_image_info[:first_image] = URI.join(request.url, "/system/three_sixty_images/#{three_sixty_image_info_query.first[1]}/#{three_sixty_image_info_query.first[0]}").to_s
        three_sixty_image_info[:rotation_speed] = three_sixty_image_info_query.last[4]
        three_sixty_image_info[:rotations_count] = three_sixty_image_info_query.last[3]
        three_sixty_image_info[:clockwise] = three_sixty_image_info_query.last[2]
        three_sixty_image_info[:plane_images_urls] = []
        three_sixty_image_info_query.each_with_index do |plane_image, index|
          three_sixty_image_info[:plane_images_urls].push(URI.join(request.url, "/system/three_sixty_images/#{three_sixty_image_info_query[index][1]}/#{three_sixty_image_info_query[index][0]}").to_s)
        end
      end
      variant_info[:three_sixty_image] = three_sixty_image_info
      
      variant_with_images = @variant_images_info.select { |branch| branch.last == variant.id }
      variant_with_images_info = []
      variant_with_images.each do |variant_image|
        variant_image_id = variant_image[0].to_s.rjust(3, '0')
        variant_with_images_info.push(URI.join(request.url, "/system/variant_images/images/000/000/#{variant_image_id}/original/#{variant_image[1]}").to_s)
      end
      variant_info[:variant_images] = variant_with_images_info
      #variant.variant_images.each do |variant_image|
        #variant_info[:variant_images].push(URI.join(request.url, variant_image.image.url).to_s)
      #end
      #binding.pry
      @variants_info.push variant_info
    end
    respond_to do |format|
      format.json #{ render status: :ok, :callback => params[:callback] }
    end
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
