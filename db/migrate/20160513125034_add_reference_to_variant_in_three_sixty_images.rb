class AddReferenceToVariantInThreeSixtyImages < ActiveRecord::Migration
  def change
    add_reference :variants, :three_sixty_image, index: true, foreign_key: true
  end
end
