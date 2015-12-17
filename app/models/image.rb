class Image < ActiveRecord::Base
  has_many :images_variants, dependent: :destroy
  has_many :variants, through: :images_variants, dependent: :destroy
end
