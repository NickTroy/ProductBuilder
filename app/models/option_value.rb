class OptionValue < ActiveRecord::Base
  belongs_to :option
  has_many :variants_option_values, dependent: :destroy
  has_many :variants, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :variants
end
