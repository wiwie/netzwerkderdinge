class AddDingTypToDings < ActiveRecord::Migration
  def up
    add_reference :dings, :ding_typ, index: true, foreign_key: true

    # clean up
    @empty_dings = Ding.where(:indegree => 0).where(:outdegree => 0)
    @empty_dings_2 = Ding.where(:name => nil)

    DingHasTyp.where(:ding => @empty_dings).destroy_all
    DingHasTyp.where(:ding => @empty_dings_2).destroy_all
    DingHasTyp.where(:ding => nil).destroy_all
    DingHasTyp.where(:ding_typ => nil).destroy_all
    DingHasTyp.where("NOT ding_typ_id in (?)", DingTyp.all.collect{|x| x.id}).destroy_all

    @empty_asses = Assoziation.where("ding_eins_id IN (?) OR ding_zwei_id IN (?)", @empty_dings.collect{|x| x.id}, @empty_dings.collect{|x| x.id})
    @empty_asses_2 = Assoziation.where("ding_eins_id IN (?) OR ding_zwei_id IN (?)", @empty_dings_2.collect{|x| x.id}, @empty_dings_2.collect{|x| x.id})

    @empty_user_asses = UserAssoziation.where(:assoziation => @empty_asses)
    @empty_user_asses_2 = UserAssoziation.where(:assoziation => @empty_asses_2)

    @empty_user_asses.destroy_all
    @empty_user_asses_2.destroy_all

    @empty_asses.destroy_all
    @empty_asses_2.destroy_all

    @empty_dings.destroy_all
    @empty_dings_2.destroy_all

    DingHasTyp.all.each do |ding_has_typ|
    	@old_ding = ding_has_typ.ding
    	@new_ding_with_typ = Ding
            .where(:name => @old_ding.name)
            .where(:published => @old_ding.published)
            .where(:indegree => 0)
            .where(:outdegree => 0)
    		.where(:ding_typ => ding_has_typ.ding_typ).first_or_create

    	# now "redirect" the user's assoziationen
    	@user = ding_has_typ.user
    	# user asses for the ding we are just about to change
    	if @user
	    	@user.user_assoziations
    			.joins(:assoziation)
    			.where("assoziations.ding_eins_id = ?", @old_ding.id).each do |user_ass|
    				ass = user_ass.assoziation
    				new_ass = Assoziation
    							.where(:ding_eins => @new_ding_with_typ)
    							.where(:ding_zwei => ass.ding_zwei).first_or_create

    				user_ass.assoziation = new_ass
    				user_ass.save()
    		end

    		@user.user_assoziations
    			.joins(:assoziation)
    			.where("assoziations.ding_zwei_id = ?", @old_ding.id).each do |user_ass|
    				ass = user_ass.assoziation
    				new_ass = Assoziation
    							.where(:ding_eins => ass.ding_eins)
    							.where(:ding_zwei => @new_ding_with_typ).first_or_create

    				user_ass.assoziation = new_ass
    				user_ass.save()
    		end
	    end

        Favorit
            .where(:ding => @old_ding)
            .where(:user => @user)
            .update_all(ding_id: @new_ding_with_typ)
    end

    # delete those. which are now not associated anymore
    @empty_dings = Ding.where(:indegree => 0).where(:outdegree => 0)
    @empty_dings.destroy_all

    Assoziation.select{|a| a.user_assoziations.count == 0}.each {|a| a.delete}
    Ding.select{|d| d.assoziations.count == 0 and d.eingehende_assoziations.count == 0}.each {|d| d.delete}

  end

  def down
  	remove_reference :dings, :ding_typ
  end
end
