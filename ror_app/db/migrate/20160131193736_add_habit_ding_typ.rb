class AddHabitDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Habit')
  end

  def down
  	DingTyp.find_by_name('Habit').delete
  end
end
