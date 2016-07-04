class AddAzureImageColumnToProductImage < ActiveRecord::Migration
  def self.up
    change_table :product_images do |t|
      t.attachment :azure_image
    end
  end

  def self.down
    remove_attachment :product_images, :azure_image
  end
end
