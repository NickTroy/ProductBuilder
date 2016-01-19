class AddColumnOrderNumberToOptions < ActiveRecord::Migration
  def change
    add_column :options, :order_number, :integer
  end
end
