class Option < ActiveRecord::Base
  has_many :option_values, dependent: :destroy
  has_many :products_options, dependent: :destroy
end
