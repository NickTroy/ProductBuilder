json.variants @variants do |variant|
  json.variant_id variant.id
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
  unless variant.main_image_id.nil?
    json.image_source VariantImage.find(variant.main_image_id).image.url 
  else 
    json.image_source ''
  end
  json.price variant.price
end  
