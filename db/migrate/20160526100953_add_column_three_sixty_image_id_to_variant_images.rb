class AddColumnThreeSixtyImageIdToVariantImages < ActiveRecord::Migration
  def change
    add_reference :variant_images, :three_sixty_image, index: true, foreign_key: true
  end
end
