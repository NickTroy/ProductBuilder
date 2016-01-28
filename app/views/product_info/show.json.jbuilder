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
    json.image_source ''
    json.three_sixty_image do
      unless variant.three_sixty_image.plane_images.empty?
        json.first_image asset_url(variant.three_sixty_image.plane_images.first.image)
        json.plane_images_urls variant.three_sixty_image.plane_images do |plane_image|
          json.plane_image_url asset_url(plane_image.image.url)
        end
      end
    end
  elsif !(variant.main_image_id.nil?)
    json.image_source asset_url(VariantImage.find(variant.main_image_id).image.url)
    json.three_sixty_image ''
  else 
    json.image_source ''
    json.three_sixty_image ''
  end
  json.price variant.price
end  
