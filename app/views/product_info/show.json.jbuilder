unless @first_image.nil?
  json.product_first_image_source asset_url(@first_image.image.url)
end
json.option_dependency @option_dependency
json.options @product_options do |option|
  json.option_name option[:option_name]
  json.option_order_number option[:order_number]
  json.option_values option[:option_values] do |option_value|
    json.option_value option_value
  end
end
json.main_variant_id @main_variant_id
json.variants @variants do |variant|
  json.variant_id variant.id
  json.pseudo_product_variant_id variant.pseudo_product_variant_id
  
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  if !(variant.three_sixty_image.nil?)
    json.three_sixty_image do
      unless variant.three_sixty_image.plane_images.empty?
        json.first_image asset_url(variant.three_sixty_image.plane_images.first.image.url)
        json.rotation_speed variant.three_sixty_image.rotation_speed
        json.rotations_count variant.three_sixty_image.rotations_count
        json.clockwise variant.three_sixty_image.clockwise
        json.plane_images_urls variant.three_sixty_image.plane_images do |plane_image|
          json.plane_image_url asset_url(plane_image.image.url)
        end
      end
    end
  else 
    json.three_sixty_image ''
  end
  json.variant_images variant.variant_images do |variant_image|
    json.image_source asset_url(variant_image.image.url)
  end 
  json.price variant.price
end  
