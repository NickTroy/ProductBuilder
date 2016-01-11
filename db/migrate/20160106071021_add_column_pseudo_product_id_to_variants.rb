class AddColumnPseudoProductIdToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :pseudo_product_id, :integer
  end
end
