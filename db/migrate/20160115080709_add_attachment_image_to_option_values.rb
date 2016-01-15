class AddAttachmentImageToOptionValues < ActiveRecord::Migration
  def self.up
    change_table :option_values do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :option_values, :image
  end
end
