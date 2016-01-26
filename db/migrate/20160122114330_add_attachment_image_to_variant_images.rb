class AddAttachmentImageToVariantImages < ActiveRecord::Migration
  def self.up
    change_table :variant_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :variant_images, :image
  end
end
