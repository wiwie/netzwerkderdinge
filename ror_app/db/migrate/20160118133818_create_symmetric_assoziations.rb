class CreateSymmetricAssoziations < ActiveRecord::Migration
  def up
  	Assoziation.all.each do |ass|
  		new_ass = Assoziation.create(:ding_eins => ass.ding_zwei, :ding_zwei => ass.ding_eins)
  		ass.user_assoziations.each do |userass|
  			UserAssoziation.create(:assoziation => new_ass, :user => userass.user, :published => userass.published)
  		end
  	end
  end

  def down
  	asses = Assoziation.where('ding_eins_id > ding_zwei_id')

  	UserAssoziation.where(:assoziation => asses).destroy_all

  	asses.destroy_all
  end
end
