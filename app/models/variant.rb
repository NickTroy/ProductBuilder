class Variant < ActiveRecord::Base
  has_many :variants_option_values, dependent: :destroy
  has_many :option_values, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :option_values
  belongs_to :product_image
  has_many :variant_images, dependent: :destroy
end
