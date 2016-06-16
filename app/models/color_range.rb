class ColorRange < ActiveRecord::Base
  has_many :option_values
  
  validates :name, presence: true, uniqueness: true   
end
