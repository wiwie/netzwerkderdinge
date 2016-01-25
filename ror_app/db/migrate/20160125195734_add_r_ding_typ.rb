class AddRDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'R')
  end

  def down
  	DingTyp.find(:name => 'R').delete
  end
end
