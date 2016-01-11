class RemoveProductIdFromOptions < ActiveRecord::Migration
  def change
    remove_column :options, :product_id, :integer
  end
end
