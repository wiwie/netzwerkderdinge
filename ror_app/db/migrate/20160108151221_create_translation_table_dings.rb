class CreateTranslationTableDings < ActiveRecord::Migration
  def up
  	Ding.create_translation_table!({
       :name => :string, 
       :description => :text
    }, {
      :migrate_data => true
    })
  end

  def down
    Ding.drop_translation_table!
  end
end
