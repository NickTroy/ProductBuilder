class CreateProductsOptions < ActiveRecord::Migration
  def change
    create_table :products_options do |t|
      t.integer :product_id
      t.references :option, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
