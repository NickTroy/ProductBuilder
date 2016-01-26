class AddAttachmentImageToPlaneImages < ActiveRecord::Migration
  def self.up
    change_table :plane_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :plane_images, :image
  end
end
