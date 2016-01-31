class AddOutdegreeToDings < ActiveRecord::Migration
  def up
    add_column :dings, :outdegree, :integer, :default => 0

    Ding.all.each do |ding|
    	ding.outdegree = Assoziation.where(:ding_eins => ding).count
    	ding.save()
    end
  end

  def down
    remove_column :dings, :outdegree
  end
end
