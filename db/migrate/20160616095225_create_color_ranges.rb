class CreateColorRanges < ActiveRecord::Migration
  def change
    create_table :color_ranges do |t|
      t.string :name
      t.string :color

      t.timestamps null: false
    end
  end
end
