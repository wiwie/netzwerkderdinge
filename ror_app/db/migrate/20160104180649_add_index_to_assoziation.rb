class AddIndexToAssoziation < ActiveRecord::Migration
  def change
  	add_index :assoziations, [:ding_eins_id, :ding_zwei_id], :unique => true
  end
end
