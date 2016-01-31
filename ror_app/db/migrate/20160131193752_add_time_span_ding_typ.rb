class AddTimeSpanDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Time Span')
  end

  def down
  	DingTyp.find_by_name('Time Span').delete
  end
end
