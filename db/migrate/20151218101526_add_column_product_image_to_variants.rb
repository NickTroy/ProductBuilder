class AddColumnProductImageToVariants < ActiveRecord::Migration
  def change
    add_reference :variants, :product_image, index: true, foreign_key: true
  end
end
