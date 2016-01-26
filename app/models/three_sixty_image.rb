class ThreeSixtyImage < ActiveRecord::Base
  belongs_to :variant
  has_many :plane_images
end
