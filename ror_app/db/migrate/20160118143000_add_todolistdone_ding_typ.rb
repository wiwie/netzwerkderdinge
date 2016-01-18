class AddTodolistdoneDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo List Done')
  end

  def down
  	DingTyp.find(:name => 'Todo List Done').delete
  end
end
