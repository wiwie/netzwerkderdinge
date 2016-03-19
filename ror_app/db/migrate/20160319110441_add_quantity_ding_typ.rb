class AddQuantityDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Quantity')
  end

  def down
  	DingTyp.find(:name => 'Quantity').delete
  end
end
