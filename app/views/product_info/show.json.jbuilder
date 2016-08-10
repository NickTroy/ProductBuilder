unless @first_image.nil?
  json.product_first_image_source asset_url(@first_image.azure_image.url)
end
json.option_dependency @option_dependency
json.color_and_material_values @color_and_material_values
json.option_groups @product_option_groups do |option_group|
  json.option_group_name option_group.name
  json.option_group_prefix option_group.prefix
  json.options option_group.options do |option|
    unless @product_options.find { |product_option| product_option[:option_name] == option.name }.nil?  
      json.option_name option.name
      json.option_order_number option.order_number
    end
  end
end
json.slider_images_params @slider_images_params do |slider_images_param|
  json.product_type slider_images_param.product_type
  json.base_size_ratio slider_images_param.base_size_ratio
end
json.color_ranges @color_ranges do |color_range|
  json.name color_range[:name]
  json.color color_range[:color]
  json.option_values color_range[:option_values] 
end
json.options @product_options do |option|
  json.option_name option[:option_name]
  json.option_order_number option[:order_number]
  json.option_values option[:option_values] do |option_value|
    json.option_value option_value
  end
end
json.main_variant_id @main_variant_id
json.main_variant do
  json.id @main_variant.id
  json.pseudo_product_variant_id @main_variant.pseudo_product_variant_id
  
  json.color_range_name @main_variant_color_range
  json.length @main_variant.length
  json.depth @main_variant.depth
  json.height @main_variant.height

  json.price @main_variant.price
  json.sku @main_variant.sku
  
  json.why_we_love_this @main_variant.why_we_love_this
  json.care_instructions @main_variant.care_instructions

  json.options @main_variant.option_values.each do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  if @main_variant.three_sixty_image.nil?
    json.three_sixty_image ''
  elsif @main_variant.three_sixty_image.plane_images.empty?
    json.three_sixty_image ''
  else
    json.three_sixty_image do
      json.first_image asset_url(@main_variant.three_sixty_image.plane_images.first.azure_image.url)
      json.rotation_speed @main_variant.three_sixty_image.rotation_speed
      json.rotations_count @main_variant.three_sixty_image.rotations_count
      json.clockwise @main_variant.three_sixty_image.clockwise
      json.caption_3d_image @main_variant.three_sixty_image.caption_3d_image
      json.plane_images_urls @main_variant.three_sixty_image.plane_images.each do |plane_image|
        json.plane_image_url asset_url(plane_image.azure_image.url)
      end
    end
  end
  if @main_variant.three_sixty_image.nil?
    json.variant_images []
  else
    json.variant_images @main_variant.three_sixty_image.variant_images.each do |variant_image|
      json.image_source asset_url(variant_image.azure_image.url)
      json.image_caption variant_image.caption
    end
  end
end

json.product_data do
  json.(@product_info, :why_we_love_this, :be_sure_to_note, :country_of_origin, :primary_materials, :requires_assembly, 
                       :care_instructions, :shipping_restrictions, :return_policy)
  if @product_info.lead_time.nil? or @product_info.lead_time_unit.nil?
    json.lead_time "not set"
  else
    json.lead_time do
      json.number @product_info.lead_time 
      json.period @product_info.lead_time_unit
    end
  end
  
  if @shipping_method.nil?
    json.shipping_method nil
  else
    json.shipping_method do
      json.(@shipping_method, :name, :description)
      
      if @shipping_method.lead_time.nil? or @shipping_method.lead_time_unit.nil?
        json.lead_time "not set"
      else
        json.lead_time do
          json.number @shipping_method.lead_time 
          json.period @shipping_method.lead_time_unit
        end
      end
    end
  end
  json.(@main_variant, :sku, :price, :length, :condition, :height, :room, :depth, :weight)
end

json.sketch_front_image @sketch_front_image.nil? ? "" : asset_url(@sketch_front_image.azure_image.url)
json.sketch_back_image @sketch_back_image.nil? ? "" : asset_url(@sketch_back_image.azure_image.url)
