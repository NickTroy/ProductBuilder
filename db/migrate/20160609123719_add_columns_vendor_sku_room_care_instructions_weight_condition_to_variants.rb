class AddColumnsVendorSkuRoomCareInstructionsWeightConditionToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :vendor_sku, :string
    add_column :variants, :room, :string
    add_column :variants, :care_instructions, :text
    add_column :variants, :weight, :integer
    add_column :variants, :condition, :string
  end
end
