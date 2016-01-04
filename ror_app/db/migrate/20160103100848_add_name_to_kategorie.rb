class AddNameToKategorie < ActiveRecord::Migration
  def change
    add_column :kategories, :name, :string
  end
end
