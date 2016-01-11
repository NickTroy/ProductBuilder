class ChangeProductIdTypeInVariants < ActiveRecord::Migration
  def self.up
    change_table :variants do |t|
      t.change :product_id, :integer, :limit => 8
    end
  end
  
  def self.down
    change_table :variants do |t|
      t.change :product_id, :integer, :limit => 4
    end
  end
end
