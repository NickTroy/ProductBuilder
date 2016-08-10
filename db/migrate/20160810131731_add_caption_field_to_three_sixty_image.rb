class AddCaptionFieldToThreeSixtyImage < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :caption_3d_image, :string
  end
end
