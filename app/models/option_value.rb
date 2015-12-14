class OptionValue < ActiveRecord::Base
  belongs_to :option
  has_many :variants_options
  has_many :variants, through: :variants_options
end
