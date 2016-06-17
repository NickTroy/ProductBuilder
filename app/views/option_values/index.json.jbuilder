json.array! @option_values do |option_value|
  json.id option_value.id
  json.value option_value.value
  json.image_url asset_url(option_value.image.url)
end
