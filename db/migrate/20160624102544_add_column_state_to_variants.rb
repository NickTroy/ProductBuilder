class AddColumnStateToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :state, :boolean, :default => true
  end
end
