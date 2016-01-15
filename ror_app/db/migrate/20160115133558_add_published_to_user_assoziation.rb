class AddPublishedToUserAssoziation < ActiveRecord::Migration
  def up
    add_column :user_assoziations, :published, :boolean, :default => true
  end

  def down
    remove_column :user_assoziations, :published
  end
end
