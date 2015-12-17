class Variant < ActiveRecord::Base
  has_many :variants_option_values, dependent: :destroy
  has_many :option_values, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :option_values
  has_many :images_variants, dependent: :destroy
  has_many :images, through: :images_variants, dependent: :destroy
end
