class AddPublishedToDing < ActiveRecord::Migration
  def up
    add_column :dings, :published, :boolean, :default => false
    @ding_ids_1 = Assoziation.joins(:user_assoziations).where(:user_assoziations => {:published => true}).collect {|x| x.ding_eins_id}
    @ding_ids_2 = Assoziation.joins(:user_assoziations).where(:user_assoziations => {:published => true}).collect {|x| x.ding_zwei_id}
    Ding.where(:id => @ding_ids_1).update_all(published: true)
    Ding.where(:id => @ding_ids_2).update_all(published: true)
  end

  def down
    remove_column :dings, :published
  end
end
