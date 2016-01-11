json.array! @variants do |variant|
  json.variant_id variant.id
  if !(variant.product_image.nil?)
    json.image_source variant.product_image.image.url(:thumb) 
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