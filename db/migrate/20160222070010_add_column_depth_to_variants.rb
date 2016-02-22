class AddColumnDepthToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :depth, :string
  end
end
