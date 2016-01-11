class CreateImagesVariants < ActiveRecord::Migration
  def change
    create_table :images_variants do |t|
      t.references :image, index: true, foreign_key: true
      t.references :variant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
