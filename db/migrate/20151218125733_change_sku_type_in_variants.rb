class ChangeSkuTypeInVariants < ActiveRecord::Migration
  def self.up
    change_table :variants do |t|
      t.change :sku, :string
    end
  end
  
  def self.down
    change_table :variants do |t|
      t.change :sku, :integer
    end
  end
end
