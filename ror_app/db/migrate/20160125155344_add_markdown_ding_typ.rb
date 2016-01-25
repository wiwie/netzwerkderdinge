class AddMarkdownDingTyp < ActiveRecord::Migration
  def up
  	DingTyp.create(:name => 'Markdown')
  end

  def down
  	DingTyp.find(:name => 'Markdown').delete
  end
end
