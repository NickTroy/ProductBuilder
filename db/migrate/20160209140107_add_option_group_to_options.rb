class AddOptionGroupToOptions < ActiveRecord::Migration
  def change
    add_reference :options, :option_group, index: true, foreign_key: true
  end
end
