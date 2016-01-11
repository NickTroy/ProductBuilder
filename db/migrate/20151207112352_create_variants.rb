class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.integer :product_id

      t.timestamps null: false
    end
  end
end
