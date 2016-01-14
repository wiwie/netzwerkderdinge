class AddVideoDingTyp < ActiveRecord::Migration
  def change
  	DingTyp.create(:name => 'Video')
  end
end
