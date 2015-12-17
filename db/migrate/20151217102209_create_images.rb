class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :product_id
      t.text :image_source
      t.string :title

      t.timestamps null: false
    end
  end
end
