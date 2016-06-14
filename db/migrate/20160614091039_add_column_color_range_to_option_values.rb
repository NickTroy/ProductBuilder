class AddColumnColorRangeToOptionValues < ActiveRecord::Migration
  def change
    add_column :option_values, :color_range, :string
  end
end
