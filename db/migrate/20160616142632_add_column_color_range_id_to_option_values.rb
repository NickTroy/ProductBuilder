class AddColumnColorRangeIdToOptionValues < ActiveRecord::Migration
  def change
    add_reference :option_values, :color_range, index: true, foreign_key: true
  end
end
