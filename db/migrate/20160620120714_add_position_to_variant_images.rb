class AddPositionToVariantImages < ActiveRecord::Migration
  def change
    add_column :variant_images, :position, :integer, :default => 0
  end
end
