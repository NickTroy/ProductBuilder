class ProductImage < ActiveRecord::Base
  has_many :variants, dependent: :destroy
end
