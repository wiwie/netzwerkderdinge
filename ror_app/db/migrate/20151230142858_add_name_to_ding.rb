class AddNameToDing < ActiveRecord::Migration
  def change
    add_column :dings, :name, :string
  end
end
