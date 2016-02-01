class AddDefaultDingTypId < ActiveRecord::Migration
  def up
  	change_column_default :dings, :ding_typ_id, 1

  	Ding.where(:ding_typ => nil).update_all(ding_typ_id: DingTyp.find_by_name("Ding").id)
  end
end
