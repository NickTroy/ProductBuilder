class AddColumnLengthToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :length, :string
  end
end
