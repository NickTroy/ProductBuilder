class AddDetailsToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :price, :decimal
    add_column :variants, :sku, :integer
  end
end
