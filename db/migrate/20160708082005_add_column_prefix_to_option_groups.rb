class AddColumnPrefixToOptionGroups < ActiveRecord::Migration
  def change
    add_column :option_groups, :prefix, :string, :default => "Select"
  end
end
