class CreateDefaultCaptions < ActiveRecord::Migration
  def change
    create_table :default_captions do |t|
      
      t.string :image_number
      t.string :default_caption

      t.timestamps null: false
    end
  end
end
