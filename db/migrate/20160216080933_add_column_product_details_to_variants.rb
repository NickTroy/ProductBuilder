class AddColumnProductDetailsToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :product_details, :text
  end
end
