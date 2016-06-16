class RemoveColumnColorRangeFromOptionValues < ActiveRecord::Migration
  def change
    remove_column :option_values, :color_range, :string
  end
end
