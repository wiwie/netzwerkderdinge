class CreateDingHasTyps < ActiveRecord::Migration
  def up
    create_table :ding_has_typs do |t|
      t.references :ding, index: true, foreign_key: true
      t.references :ding_typ, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :ding_has_typs, [:ding_id, :ding_typ_id, :user_id], :unique => true, :name => :ding_has_typs_index
    Ding.all.each do |ding|
    	DingHasTyp.create(ding: ding, ding_typ: ding.ding_typ, user: User.find(1))
    end
  end

  def down
    drop_table :ding_has_typs
  end
end
