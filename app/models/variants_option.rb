class VariantsOption < ActiveRecord::Base
  belongs_to :variant
  belongs_to :option
end
