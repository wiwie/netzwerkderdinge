class CreateKategories < ActiveRecord::Migration
  def change
    create_table :kategories do |t|

      t.timestamps null: false
    end
  end
end
