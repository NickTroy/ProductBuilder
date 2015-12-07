class CreateOptionValues < ActiveRecord::Migration
  def change
    create_table :option_values do |t|
      t.references :option, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
