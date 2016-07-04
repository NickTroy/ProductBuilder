class AddAttachmentAzureImageToVariantImages < ActiveRecord::Migration
  def self.up
    change_table :variant_images do |t|
      t.attachment :azure_image
    end
  end

  def self.down
    remove_attachment :variant_images, :azure_image
  end
end
