class RemoveUserFromAssoziation < ActiveRecord::Migration
  def change
    remove_reference :assoziations, :user, index: true, foreign_key: true
  end
end
