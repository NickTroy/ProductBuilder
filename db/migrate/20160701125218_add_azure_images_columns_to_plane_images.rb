class AddAzureImagesColumnsToPlaneImages < ActiveRecord::Migration
  def self.up
    change_table :plane_images do |t|
      t.attachment :azure_image
      t.attachment :azure_big_image
    end
  end

  def self.down
    remove_attachment :plane_images, :azure_image
    remove_attachment :plane_images, :azure_big_image
  end
end
