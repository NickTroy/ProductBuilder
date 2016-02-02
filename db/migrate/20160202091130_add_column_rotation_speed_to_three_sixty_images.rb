class AddColumnRotationSpeedToThreeSixtyImages < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :rotation_speed, :string
  end
end
