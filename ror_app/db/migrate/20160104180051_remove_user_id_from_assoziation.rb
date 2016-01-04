class RemoveUserIdFromAssoziation < ActiveRecord::Migration
  def change
    remove_reference :assoziations, :user_id, index: true, foreign_key: true
  end
end
