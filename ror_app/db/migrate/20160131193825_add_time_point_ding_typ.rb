class AddTimePointDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Time Point')
  end

  def down
  	DingTyp.find_by_name("Time Point").delete
  end
end
