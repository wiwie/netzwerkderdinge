class AddQuoteDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Quote')
  end

  def down
  	DingTyp.find(:name => 'Quote').delete
  end
end
