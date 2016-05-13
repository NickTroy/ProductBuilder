class RemoveReferenceToVariantInThreeSixtyImages < ActiveRecord::Migration
  def change
    remove_reference :three_sixty_images, :variant, index: true, foreign_key: true
  end
end
