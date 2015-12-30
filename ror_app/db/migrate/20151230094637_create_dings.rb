class CreateDings < ActiveRecord::Migration
  def change
    create_table :dings do |t|

      t.timestamps null: false
    end
  end
end
