class AddDingTypToDing < ActiveRecord::Migration
  def change
    add_reference :dings, :ding_typ, index: true, foreign_key: true
  end
end
