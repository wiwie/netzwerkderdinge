class AddLatexDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'LaTeX')
  end

  def down
  	DingTyp.find(:name => 'LaTeX').delete
  end
end
