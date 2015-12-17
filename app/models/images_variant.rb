class ImagesVariant < ActiveRecord::Base
  belongs_to :image
  belongs_to :variant
end
