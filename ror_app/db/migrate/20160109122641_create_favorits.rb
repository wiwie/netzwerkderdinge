class CreateFavorits < ActiveRecord::Migration
  def change
    create_table :favorits do |t|
      t.references :ding, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  	add_index :favorits, [:ding_id, :user_id], :unique => true
  end
end
