class AddColumnTitleToThreeSixtyImages < ActiveRecord::Migration
  def change
    add_column :three_sixty_images, :title, :string
  end
end
