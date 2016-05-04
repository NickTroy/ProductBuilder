class ChangeMainProductIdInProductInfos < ActiveRecord::Migration
  def self.up
    change_table :product_infos do |t|
      t.change :main_product_id, :integer, :limit => 8
    end
  end
  
  def self.down
    change_table :product_infos do |t|
      t.change :main_product_id, :integer, :limit => 4
    end
  end
end
