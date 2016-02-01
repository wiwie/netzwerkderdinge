class RemoveDuplicateDings < ActiveRecord::Migration
  def up
  	@ding_map = {}

  	Ding.all.each do |d|
  		name = d.name
  		ding_typ_id = d.ding_typ_id
  		if not @ding_map.has_key?(name)
  			@ding_map[name] = {}
  		end
  		if not @ding_map[name].has_key?(ding_typ_id)
  			@ding_map[name][ding_typ_id] = []
  		end
  		@ding_map[name][ding_typ_id].push(d.id)
  	end

  	@ding_map.each do |name, hash|
  		hash.each do |ding_typ_id, values|
	  		d = Ding.find(values.first)
	  		@dups = values.drop(1)
	  		if @dups.count > 0
	  			puts d.name
	  		end
	  		@dups.each do |dup_id|
	  			dup = Ding.find(dup_id)
	  			Assoziation.where(:ding_eins => dup).each do |ass|
	  				@user_asses = ass.user_assoziations
	  				@new_ass = Assoziation
	  					.where(:ding_eins => d)
	  					.where(:ding_zwei => ass.ding_zwei).first_or_create
	  				@user_asses.update_all(assoziation_id: @new_ass.id)
	  				if not ass.id == @new_ass.id
	  					ass.delete
	  				end
	  			end

	  			Assoziation.where(:ding_zwei => dup).each do |ass|
	  				@user_asses = ass.user_assoziations
	  				@new_ass = Assoziation
	  					.where(:ding_eins => ass.ding_eins)
	  					.where(:ding_zwei => d).first_or_create
	  				@user_asses.update_all(assoziation_id: @new_ass.id)
	  				if not ass.id == @new_ass.id
	  					ass.delete
	  				end
	  			end
	  			
	  			Favorit.where(:ding => dup).update_all(ding_id: d.id)
	  			puts dup.assoziations.count
	  			dup.delete
	  		end
	  	end
  	end
  end
end
