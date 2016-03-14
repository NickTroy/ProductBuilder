class AddHeightAndWeightToOptionValues < ActiveRecord::Migration
  def change
    add_column :option_values, :height, :integer
    add_column :option_values, :weight, :integer
  end
end
