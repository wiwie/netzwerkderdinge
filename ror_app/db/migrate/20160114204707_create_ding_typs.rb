class CreateDingTyps < ActiveRecord::Migration
  def change
    create_table :ding_typs do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
