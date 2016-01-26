class CreateVariantImages < ActiveRecord::Migration
  def change
    create_table :variant_images do |t|
      t.references :variant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
