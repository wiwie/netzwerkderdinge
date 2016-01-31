class AddHabitCollectionDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Habit Collection')
  end

  def down
  	DingTyp.find_by_name("Habit Collection").delete
  end
end
