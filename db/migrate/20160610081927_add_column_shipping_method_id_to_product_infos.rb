class AddColumnShippingMethodIdToProductInfos < ActiveRecord::Migration
  def change
    add_reference :product_infos, :shipping_method, index: true, foreign_key: true
  end
end
