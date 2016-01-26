class CreatePlaneImages < ActiveRecord::Migration
  def change
    create_table :plane_images do |t|
      t.references :three_sixty_image, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
