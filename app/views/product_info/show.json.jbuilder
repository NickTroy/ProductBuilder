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
json.variants @variants do |variant|
  json.variant_id variant.id
  json.pseudo_product_variant_id variant.pseudo_product_variant_id
  
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  if !(variant.main_image_id.nil?)
    json.image_source asset_url(VariantImage.find(variant.main_image_id).image.url)
  else 
    json.image_source ''
  end
  json.price variant.price
end  
