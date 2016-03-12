class CreateDingTyps < ActiveRecord::Migration
  	def up
    	create_table :ding_typs do |t|
    	  	t.string :name

      		t.timestamps null: false
    	end

    	DingTyp.create(:name => 'Ding')
    	DingTyp.create(:name => 'URL')
    	DingTyp.create(:name => 'Image')
  	end

  	def down
  		DingTyp.find(:name => 'Ding').delete
  		DingTyp.find(:name => 'URL').delete
  		DingTyp.find(:name => 'Image').delete
  	end
end
