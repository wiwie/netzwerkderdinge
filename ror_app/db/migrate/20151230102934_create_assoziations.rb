class CreateAssoziations < ActiveRecord::Migration
  def change
    create_table :assoziations do |t|
      t.belongs_to :ding_eins, :class_name => "Ding", index: true, foreign_key: true, null: false
	  t.belongs_to :ding_zwei, :class_name => "Ding", index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_index :assoziations, [:ding_eins_id, :ding_zwei_id, :user_id], :unique => true, :name => :assoziation_index
  end
end
