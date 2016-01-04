class AddIndexToUserAssoziation < ActiveRecord::Migration
  def change
  	add_index :user_assoziations, [:assoziation_id, :user_id], :unique => true
  end
end
