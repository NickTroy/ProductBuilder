json.first_plane_image @first_plane_image
json.images_path @images_path
json.images_names @images_names
json.rotation_speed @three_sixty_image.rotation_speed
json.rotations_count @three_sixty_image.rotations_count
json.clockwise @three_sixty_image.clockwise
json.variant_images @variant_images do |variant_image|
  json.image_url asset_url(variant_image.azure_image.url)
end
