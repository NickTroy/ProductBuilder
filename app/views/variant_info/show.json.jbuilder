json.id @variant.id
json.pseudo_product_variant_id @variant.pseudo_product_variant_id

json.length @variant.length
json.depth @variant.depth
json.height @variant.height

json.price @variant.price
json.sku @variant.sku

json.options @option_values.each do |option_value|
  json.option_name option_value.option.name
  json.option_value option_value.value
end
if @three_sixty_image.nil?
 json.three_sixty_image ''
else
  json.three_sixty_image do
    json.first_image asset_url(@three_sixty_image.plane_images.first.image.url)
    json.rotation_speed @three_sixty_image.rotation_speed
    json.rotations_count @three_sixty_image.rotations_count
    json.clockwise @three_sixty_image.clockwise
    json.plane_images_urls @three_sixty_image.plane_images.each do |plane_image|
      json.plane_image_url asset_url(plane_image.image.url)
    end
  end
end
json.variant_images @variant_images.each do |variant_image|
  json.image_source asset_url(variant_image.image.url)
end