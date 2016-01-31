class AddStartTimePointDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Start Time Point')
  end

  def down
  	DingTyp.find_by_name("Start Time Point").delete
  end
end
