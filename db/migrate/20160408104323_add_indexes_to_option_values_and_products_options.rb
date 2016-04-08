class AddIndexesToOptionValuesAndProductsOptions < ActiveRecord::Migration
  def change
      add_index "products_options", ["product_id"], name: "index_products_options_on_product_id", using: :btree
      add_index "option_values", ["value"], name: "index_option_values_on_value", using: :btree
  end
end
