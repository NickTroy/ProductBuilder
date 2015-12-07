class Option < ActiveRecord::Base
  has_many :option_values, dependent: :destroy
end
