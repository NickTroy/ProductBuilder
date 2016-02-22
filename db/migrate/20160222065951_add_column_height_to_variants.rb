class AddColumnHeightToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :height, :string
  end
end
