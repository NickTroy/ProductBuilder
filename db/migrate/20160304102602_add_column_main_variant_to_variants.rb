class AddColumnMainVariantToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :main_variant, :boolean
  end
end
