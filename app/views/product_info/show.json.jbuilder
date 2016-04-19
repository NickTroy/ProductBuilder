unless @first_image.nil?
  json.product_first_image_source asset_url(@first_image.image.url)
end
json.product_details @variants.last.product_details
json.option_dependency @option_dependency
json.option_groups @product_option_groups do |option_group|
  json.option_group_name option_group.name
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
json.options @product_options do |option|
  json.option_name option[:option_name]
  json.option_order_number option[:order_number]
  json.option_values option[:option_values] do |option_value|
    json.option_value option_value
    unless OptionValue.where(:value => option_value)[0].image.url.include? "missing"
      json.image_source asset_url(OptionValue.where(:value => option_value)[0].image.url(:thumb))
    end
  end
end
json.main_variant_id @main_variant_id
json.main_variant do
  json.id @main_variant.id
  json.pseudo_product_variant_id @main_variant.pseudo_product_variant_id

  json.length @main_variant.length
  json.depth @main_variant.depth
  json.height @main_variant.height

  json.price @main_variant.price
  json.sku @main_variant.sku

  json.options @main_variant.option_values.each do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  if @main_variant.three_sixty_image.nil?
    json.three_sixty_image ''
  else
    json.three_sixty_image do
      json.first_image asset_url(@main_variant.three_sixty_image.plane_images.first.image.url)
      json.rotation_speed @main_variant.three_sixty_image.rotation_speed
      json.rotations_count @main_variant.three_sixty_image.rotations_count
      json.clockwise @main_variant.three_sixty_image.clockwise
      json.plane_images_urls @main_variant.three_sixty_image.plane_images.each do |plane_image|
        json.plane_image_url asset_url(plane_image.image.url)
      end
    end
  end
  json.variant_images @main_variant.variant_images.each do |variant_image|
    json.image_source asset_url(variant_image.image.url)
  end
end

json.sketch_front_image @sketch_front_image.nil? ? "" : asset_url(@sketch_front_image.image.url)
json.sketch_back_image @sketch_back_image.nil? ? "" : asset_url(@sketch_back_image.image.url)
json.variants @variants_info do |variant_info|
  json.variant_id variant_info[:variant_id]
  json.pseudo_product_variant_id variant_info[:pseudo_product_variant_id]

  json.length variant_info[:length]
  json.depth variant_info[:depth]
  json.height variant_info[:height]
  
  json.price variant_info[:price]
  json.sku variant_info[:sku]
  
  json.options variant_info[:options] do |option_and_value|
    json.option_name option_and_value[0]
    json.option_value option_and_value[1]
  end
  if variant_info[:three_sixty_image] == {}
    json.three_sixty_image ''
  else
    json.three_sixty_image do
      json.first_image variant_info[:three_sixty_image][:first_image]
      json.rotation_speed variant_info[:three_sixty_image][:rotation_speed]
      json.rotations_count variant_info[:three_sixty_image][:rotations_count]
      json.clockwise variant_info[:three_sixty_image][:clockwise]
      json.plane_images_urls variant_info[:three_sixty_image][:plane_images_urls] do |plane_image_url|
        json.plane_image_url plane_image_url
      end
    end
  end
  json.variant_images variant_info[:variant_images] do |variant_image_url|
    json.image_source variant_image_url
  end
end
