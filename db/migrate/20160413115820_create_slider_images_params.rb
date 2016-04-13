class CreateSliderImagesParams < ActiveRecord::Migration
  def change
    create_table :slider_images_params do |t|
      t.string :product_type
      t.text :base_size_ratio

      t.timestamps null: false
    end
  end
end
