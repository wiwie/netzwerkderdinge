class AddGoalDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Goal')
  end

  def down
  	DingTyp.find(:name => 'Goal').delete
  end
end
