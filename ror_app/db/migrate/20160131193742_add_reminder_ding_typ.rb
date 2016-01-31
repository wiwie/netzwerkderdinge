class AddReminderDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Reminder')
  end

  def down
  	DingTyp.find_by_name('Reminder').delete
  end
end
