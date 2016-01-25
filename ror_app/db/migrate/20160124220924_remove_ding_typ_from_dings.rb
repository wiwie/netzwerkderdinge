class RemoveDingTypFromDings < ActiveRecord::Migration
  def up
  	remove_column :dings, :ding_typ_id
  end
end
