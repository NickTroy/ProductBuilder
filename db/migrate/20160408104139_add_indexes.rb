class AddIndexes < ActiveRecord::Migration
  def change
     add_index "options", ["name"], name: "index_options_on_name", using: :btree

  end
end
