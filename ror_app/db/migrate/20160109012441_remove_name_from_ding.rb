class RemoveNameFromDing < ActiveRecord::Migration
  def change
    remove_column :dings, :name, :string
  end
end
