class ChangeProductIdTypeInProductsOptions < ActiveRecord::Migration
  def self.up
    change_table :products_options do |t|
      t.change :product_id, :integer, :limit => 8
    end
  end
  
  def self.down
    change_table :products_options do |t|
      t.change :product_id, :integer, :limit => 4
    end
  end
end
