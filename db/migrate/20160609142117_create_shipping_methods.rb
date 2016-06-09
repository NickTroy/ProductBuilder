class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.string :name
      t.text :description
      t.string :lead_time
      t.string :lead_time_unit

      t.timestamps null: false
    end
  end
end
