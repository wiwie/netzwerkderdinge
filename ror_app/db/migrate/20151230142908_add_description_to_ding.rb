class AddDescriptionToDing < ActiveRecord::Migration
  def change
    add_column :dings, :description, :string
  end
end
