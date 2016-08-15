json.id @variant.id
json.pseudo_product_variant_id @variant.pseudo_product_variant_id

json.length @variant.length
json.depth @variant.depth
json.height @variant.height

json.price @variant.price
json.sku @variant.sku

json.why_we_love_this @variant.why_we_love_this
json.care_instructions @variant.care_instructions

json.options @option_values.each do |option_value|
  json.option_name option_value.option.name
  json.option_value option_value.value
end
if @three_sixty_image.nil?
  json.three_sixty_image ''
elsif @three_sixty_image.plane_images.empty?
  json.three_sixty_image ''
else
  json.three_sixty_image do
    json.first_image asset_url(@three_sixty_image.plane_images.first.azure_image.url)
    json.rotation_speed @three_sixty_image.rotation_speed
    json.rotations_count @three_sixty_image.rotations_count
    json.clockwise @three_sixty_image.clockwise
    
    if @three_sixty_image.caption_3d_image.blank?
        json.caption_3d_image @default_captions[0].default_caption
      else
        json.caption_3d_image @three_sixty_image.caption_3d_image
      end
    
    json.plane_images_urls @three_sixty_image.plane_images.each do |plane_image|
      json.plane_image_url asset_url(plane_image.azure_image.url)
    end
  end
end
@image_index = 1
json.variant_images @variant_images.each do |variant_image|
  json.image_source asset_url(variant_image.azure_image.url)
  if variant_image.caption.blank?
      json.image_caption @default_captions[@image_index].default_caption
      @image_index = @image_index + 1
  else
      json.image_caption variant_image.caption
  end
end
