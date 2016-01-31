class AddIndegreeToDings < ActiveRecord::Migration
  def up
    add_column :dings, :indegree, :integer, :default => 0

    Ding.all.each do |ding|
    	ding.indegree = Assoziation.where(:ding_zwei => ding).count
    	ding.save()
    end
  end

  def down
    remove_column :dings, :indegree
  end
end
