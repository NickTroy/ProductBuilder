class AddColumnMainImageIdToThreeSixtyImages < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :main_image_id, :integer
  end
end
