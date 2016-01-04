class CreateUserAssoziations < ActiveRecord::Migration
  def change
    create_table :user_assoziations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :assoziation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
