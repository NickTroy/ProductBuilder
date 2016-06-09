class AddColumnsLeadTimeLeadTimeUnitToProductInfos < ActiveRecord::Migration
  def change
    add_column :product_infos, :lead_time, :string
    add_column :product_infos, :lead_time_unit, :string
  end
end
