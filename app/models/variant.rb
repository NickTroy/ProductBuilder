class Variant < ActiveRecord::Base
  has_many :variants_options
  has_many :option_values, through: :variants_options
end
