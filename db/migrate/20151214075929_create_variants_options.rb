class CreateVariantsOptions < ActiveRecord::Migration
  def change
    create_table :variants_options do |t|
      t.references :variant, index: true, foreign_key: true
      t.references :option, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
