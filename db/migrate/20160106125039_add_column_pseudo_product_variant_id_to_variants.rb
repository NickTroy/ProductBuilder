class AddColumnPseudoProductVariantIdToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :pseudo_product_variant_id, :integer
  end
end
