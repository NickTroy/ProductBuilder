class CreateVariantsOptionValues < ActiveRecord::Migration
  def change
    create_table :variants_option_values do |t|
      t.references :variant, index: true, foreign_key: true
      t.references :option_value, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
