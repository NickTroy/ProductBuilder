class AddAttachmentBigImageToPlaneImages < ActiveRecord::Migration
  def self.up
    change_table :plane_images do |t|
      t.attachment :big_image
    end
  end

  def self.down
    remove_attachment :plane_images, :big_image
  end
end
