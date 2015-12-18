json.array! @variants do |variant|
  json.variant_id variant.id
  json.options variant.option_values do |option_value|
    json.option_name option_value.option.name
    json.option_value option_value.value
  end
end    