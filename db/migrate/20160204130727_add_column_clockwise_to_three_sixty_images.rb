class AddColumnClockwiseToThreeSixtyImages < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :clockwise, :boolean
  end
end
