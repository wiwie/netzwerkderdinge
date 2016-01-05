class AddDescriptionToUserAssoziation < ActiveRecord::Migration
  def change
    add_column :user_assoziations, :description, :string
  end
end
