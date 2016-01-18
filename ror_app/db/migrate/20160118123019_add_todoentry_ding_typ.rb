class AddTodoentryDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo')
  end

  def down
  	DingTyp.find(:name => 'Todo').delete
  end
end
