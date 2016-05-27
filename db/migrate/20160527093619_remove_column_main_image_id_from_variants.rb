class RemoveColumnMainImageIdFromVariants < ActiveRecord::Migration
  def change
    remove_column :variants, :main_image_id, :integer
  end
end
