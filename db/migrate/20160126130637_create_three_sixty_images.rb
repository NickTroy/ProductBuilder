class CreateThreeSixtyImages < ActiveRecord::Migration
  def change
    create_table :three_sixty_images do |t|
      t.references :variant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
