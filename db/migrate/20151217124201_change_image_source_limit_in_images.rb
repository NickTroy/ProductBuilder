class ChangeImageSourceLimitInImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.change :image_source, :text, :limit => 2.megabytes
    end
  end
  
  def self.down
    change_table :images do |t|
      t.change :image_source, :text, :limit => 65535
    end
  end
end
