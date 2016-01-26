class AddColumnMainImageIdToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :main_image_id, :integer
  end
end
