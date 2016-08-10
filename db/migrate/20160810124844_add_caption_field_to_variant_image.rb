class AddCaptionFieldToVariantImage < ActiveRecord::Migration
  def change
    add_column :variant_images, :caption, :string
  end
end
