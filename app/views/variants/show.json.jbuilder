json.array! @variants do |variant|
  if variant.main_variant
    json.main_variant_id variant.id
  end
  json.variant_id variant.id
  unless variant.main_image_id.nil?
    json.image_source VariantImage.find(variant.main_image_id).image.url(:thumb) 
  end
  if !(variant.sku.nil?)
    json.sku variant.sku 
  end
  if !(variant.price.nil?)
    json.price variant.price 
  end
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
end    
