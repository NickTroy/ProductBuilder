class AddColumnsCountryOfOriginPrimaryMaterialsRequiresAssemblyCareInstructionsShippingRestrictionsReturnPolicyToProductInfos < ActiveRecord::Migration
  def change
    add_column :product_infos, :country_of_origin, :string
    add_column :product_infos, :primary_materials, :string
    add_column :product_infos, :requires_assembly, :boolean
    add_column :product_infos, :care_instructions, :text
    add_column :product_infos, :shipping_restrictions, :text
    add_column :product_infos, :return_policy, :text
  end
end
