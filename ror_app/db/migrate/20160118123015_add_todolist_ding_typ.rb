class AddTodolistDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo List')
  end

  def down
  	DingTyp.find(:name => 'Todo List').delete
  end
end
