class AddDefaultToDingTypId < ActiveRecord::Migration
  def change
  	change_column_default :dings, :ding_typ_id, 1
  end
end
