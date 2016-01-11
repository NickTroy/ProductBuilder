class RenameImagesToProductImages < ActiveRecord::Migration
  def self.up
    rename_table :images, :product_images
  end

  def self.down
    rename_table :product_images, :images
  end
end
