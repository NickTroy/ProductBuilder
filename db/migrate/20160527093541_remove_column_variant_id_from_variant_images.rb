class RemoveColumnVariantIdFromVariantImages < ActiveRecord::Migration
  def change
    remove_reference :variant_images, :variant, index: true, foreign_key: true
  end
end
