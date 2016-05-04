class CreateProductInfos < ActiveRecord::Migration
  def change
    create_table :product_infos do |t|
      t.string :handle
      t.integer :main_product_id

      t.timestamps null: false
    end
  end
end
