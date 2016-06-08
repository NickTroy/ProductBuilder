class AddColumnsBeSureToNoteToProductInfos < ActiveRecord::Migration
  def change
    add_column :product_infos, :be_sure_to_note, :text
    add_column :product_infos, :why_we_love_this, :text
  end
end
