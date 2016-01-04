class AddKategorieToDing < ActiveRecord::Migration
  def change
    add_reference :dings, :kategorie, index: true, foreign_key: true
  end
end
