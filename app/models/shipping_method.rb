class ShippingMethod < ActiveRecord::Base
  has_many :product_infos, dependent: :nullify
  
  validates :name, presence: true, uniqueness: true    
end
