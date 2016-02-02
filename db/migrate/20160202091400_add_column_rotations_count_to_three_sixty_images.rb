class AddColumnRotationsCountToThreeSixtyImages < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :rotations_count, :string
  end
end
