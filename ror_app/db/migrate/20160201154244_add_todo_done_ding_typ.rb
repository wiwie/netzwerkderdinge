class AddTodoDoneDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Todo Fail')
  end

  def down
  	DingTyp.find_by_name("Todo Fail").delete
  end
end
