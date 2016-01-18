class AddTodoentrydoneDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo Done')
  end

  def down
  	DingTyp.find(:name => 'Todo Done').delete
  end
end
