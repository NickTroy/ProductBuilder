unless @first_image.nil?
  json.product_first_image_source asset_url(@first_image.image.url)
end
json.options @product_options do |option|
  json.option_name option.name
  json.option_values option.option_values do |option_value|
    json.option_value option_value.value
  end
end
json.variants @variants do |variant|
  json.variant_id variant.id
  json.pseudo_product_variant_id variant.pseudo_product_variant_id
  
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  if !(variant.product_image.nil?)
    json.image_source asset_url(variant.product_image.image.url)
  else 
    json.image_source ''
  end
  json.price variant.price
end  