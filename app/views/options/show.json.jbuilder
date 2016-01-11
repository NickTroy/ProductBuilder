json.option_name @option.name
json.array! @option_values do |option_value|
  json.value option_value.value
end