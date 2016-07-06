class AddColumnWhyWeLoveThisToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :why_we_love_this, :text
  end
end
