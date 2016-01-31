class AddTodoSkipDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo Skip')
  end

  def down
  	DingTyp.find_by_name("Todo Skip").delete
  end
end
