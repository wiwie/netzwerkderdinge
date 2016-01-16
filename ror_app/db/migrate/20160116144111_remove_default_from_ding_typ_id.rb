class RemoveDefaultFromDingTypId < ActiveRecord::Migration
  def change
  	change_column_default(:dings, :ding_typ_id, nil)
  end
end
