class AddVideoDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Video')
  end
end
