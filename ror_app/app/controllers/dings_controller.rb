require 'rmagick'

class DingsController < ApplicationController
	before_action :authenticate_user!
	autocomplete :ding, :name
	
	def index
		#st = ActiveRecord::Base.connection
		#@pop_dings = st.execute('SELECT ding_id,SUM(count) count FROM
		#		(SELECT ding_eins_id ding_id,count(*) as count 
		#		FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
		#		WHERE published = "t"
		#		GROUP BY ding_eins_id)
		#		GROUP BY ding_id
		#		ORDER BY count DESC LIMIT 10;')
		#st.close()
		@pop_dings = Ding.where(:published => true).order("indegree+outdegree DESC").limit(10)

		@newest_dings = Ding.where(:published => true).order("created_at DESC").limit(10)

		@all_dings = Ding.where(:published => true).with_translations.order("name").paginate(:page => params[:page], :per_page => 10)
	end


	def autocomplete_ding_name
		term = params[:term]

		dings = Ding.with_translations
			.joins(:assoziations => :user_assoziations)
			.where("dings.published = 't' OR user_assoziations.user_id = ?", current_user.id)
			.where('name LIKE ?', term + '%')
			.order(:name).distinct

		exact_dings_ding_typ_ids = Ding.with_translations
			.joins(:assoziations => :user_assoziations)
			.where("dings.published = 't' OR user_assoziations.user_id = ?", current_user.id)
			.where('name = ?', term)
			.order(:name).distinct.collect {|d| d.ding_typ_id}


		json = dings.map { |ding| {
			:id => ding["id"], 
			:label => "<i class='fa fa-" + ding.get_symbol + "'></i> " + ding["name"],
			:value => ding["name"]} }
		if exact_dings_ding_typ_ids.count > 0
			@dings = DingTyp.where("NOT id IN (?)", exact_dings_ding_typ_ids)
		else
			@dings = DingTyp.all
		end
		@dings.order(:name).each do |ding_typ|
			json = json + [{:id => "add_new_" + ding_typ.id.to_s, 
				:label => "<i style=\"color: #777\" class='fa fa-" + Ding.get_symbol(ding_typ) + "'></i> <i style=\"color: #777\">Add new " + ding_typ.name + " '" + term + "'</i>", 
				:value => term}]
		end

		render :json => json
	end

	def has_translation(ding_id, attribute, locale)
		@ding = Ding.find(ding_id)
		return (not @ding[attribute.to_s + "_" + locale].nil?)
	end

	def add_translation()
		if params.has_key?(:ding) and params.has_key?(:locale)
			@ding = Ding.find(params[:ding_id])
			if params[:ding].has_key?(:name)
				@ding.attributes = { name: params[:ding][:name], locale: params[:locale] }
				@ding.save
			end
		end
		redirect_to(@ding)
	end

	def show
		@ding = Ding.with_translations.joins(:ding_typ).find(params[:id])

		# make sure, that the current user is allowed to show this ding;
		# if it is non-published, the user needs to have at least one assoziation to it;
		@users = UserAssoziation.where(:assoziation_id => Assoziation.where('ding_eins_id = ? OR ding_zwei_id = ?', @ding.id, @ding.id)).select(:user_id).distinct.collect {|x| x.user_id}
		@can_access = @ding.published || (@users.include?(current_user.id))
		
		if @can_access
			@ding_typ = @ding.ding_typ

			if @ding_typ.name == 'URL'
				begin
					@page_preview = LinkThumbnailer.generate(@ding.name)
				rescue
				end
			elsif @ding_typ.name == 'Todo List' or @ding_typ.name == 'Todo List Done'
				@todos = @ding.assoziierte_dinge(current_user).select {|d| d[0].ding_typ.name == 'Todo' or d[0].ding_typ.name == 'Todo List' }
				@done_todos = @ding.assoziierte_dinge(current_user).select {|d| d[0].ding_typ.name == 'Todo Done' or d[0].ding_typ.name == 'Todo List Done' }
		  		if @todos.count+@done_todos.count > 0
					@perc_finished = (@done_todos.count.to_f/(@todos.count+@done_todos.count)*100).to_i
				end
				@sublistof = Assoziation.joins(:user_assoziations, 
						:ding_eins => :ding_typ)
					.where(:ding_zwei => @ding)
					.where('ding_typs.name = ? OR ding_typs.name = ?', 'Todo List', 'Todo List Done')
			elsif @ding_typ.name == 'Todo' or @ding_typ.name == 'Todo Done'
				@todoof = Assoziation.joins(:user_assoziations,
						:ding_eins => :ding_typ)
					.where(:ding_zwei => @ding)
					.where('ding_typs.name = ? OR ding_typs.name = ?', 'Todo List', 'Todo List Done')
			elsif @ding_typ.name == 'Habit'
				@habit_info = @ding.get_habit_info(current_user)
			elsif @ding_typ.name == 'Habit Collection'
				@habit_groups = Hash[Assoziation
					.joins(:user_assoziations, :ding_zwei => :ding_typ)
					.where(:ding_eins => @ding)
					.where("ding_typs.name = ?", 'Habit')
					.where(:user_assoziations => {:user => current_user})
					.collect {|ass| [ass.ding_zwei, ass.ding_zwei.get_habit_info(current_user)]}
					.select {|habit, habit_info| not habit_info.nil?}
					.group_by {|habit, habit_info| habit_info[:ts]}
					.sort_by{|k,v| k}]
					.map {|key, habit_group| [key, habit_group.sort_by {|habit, habit_info| habit_info.nil? ? [Time.now, -5] : [habit_info[:latest_time]+habit_info[:ts], -habit_info[:streak]]}] }
			end

			if not @ding.published
				@can_toggle_publish = true
			else
				@users = UserAssoziation.where(:assoziation_id => Assoziation.where('ding_eins_id = ? OR ding_zwei_id = ?', @ding.id, @ding.id)).select(:user_id).distinct.collect {|x| x.user_id}
				@can_toggle_publish = (@users.count == 1 and @users.first == current_user.id)
			end

			#potential new assoziation
			@assoziation = Assoziation.new
		end
	end

	def description_as_png
		@ding = Ding.find(params[:ding_id])

		output = render_to_string(:template => "/dings/description_as_png.pdf.erb", :layout => true)

	    file = Tempfile.new('foo')
	    file.write output
	    file.close

	    pdf = Magick::ImageList.new(file.path)
	    png_path = file.path + ".png"
		pdf.write(png_path)

		send_file png_path, :type => "image/png", :disposition => "inline"
	end

	def r_plot
		# TODO
		#@ding = Ding.find(params[:ding_id])
		#file = Tempfile.new('foo')

	    #@@r.myplot.call(file.path, @ding.description.nil? ? '' : @ding.description)

	    #send_file file, :type => "image/png", :disposition => "inline"
	  end

	def create
		@ding = Ding.new(params.require(:ding).permit(:name, :ding_typ_id))

		# TODO
		if not @ding.ding_typ
			# TODO
			@ding.ding_typ = DingTyp.find_by_name('Ding')
		end

		@ding.save()
		redirect_to @ding
	end

	# we cannot just update the existing ding; because others may have associated it.
	def update
	  @ding = Ding.find params[:id]

	  respond_to do |format|
	  	# TODO: dont change existing ding;
	  	if params[:ding].has_key?(:kategorie)
	  	  if @ding.update_attribute(:kategorie, Kategorie.find(params[:ding][:kategorie].to_i))
		    format.html { redirect_to(@ding, :notice => 'Ding was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
		  end
		elsif params[:ding].has_key?(:description)
	  	  if @ding.update_attribute(:description, params[:ding][:description])
		    format.html { redirect_to(@ding, :notice => 'Ding was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
		  end
		elsif params[:ding].has_key?(:published)
			@success = false
			#if we are unpublishing, make assoziationen consistent
			if params[:ding][:published] == 'false'
				# make sure that all assoziationen are from the current user (should be the case)
				@userasses = UserAssoziation.where(
					:assoziation_id => Assoziation.where('ding_eins_id = ? OR ding_zwei_id = ?', @ding.id, @ding.id))
			    @users = @userasses.select(:user_id).distinct.collect {|x| x.user_id}
			    # if we have more than the current user, we cannot unpublish the ding
				if not (@users.count == 1 and @users.first == current_user.id)
					format.html { redirect_to(@ding, :notice => 'Ding konnte nicht unpublished werden, da es von anderen Benutzern assoziiert wurde.') }
					format.json { respond_with_bip(@ding) }
				else
					@userasses.update_all(published: false)
					@success = true
				end
			else
				@success = true
			end

			if @success
				# now update the published attribute of the ding
				if @ding.update_attribute(:published, params[:ding][:published])
					format.html { redirect_to(@ding, :notice => 'Ding was successfully updated.') }
					format.json { respond_with_bip(@ding) }
				end
			end
	    elsif params[:ding].has_key?(:name) or params[:ding].has_key?(:ding_typ_id)
	      if params[:ding].has_key?(:name)
	      	if @ding.name == params[:ding][:name]
	      		return
	      	end
		      @new_ding = Ding.where(
		      	:name => params[:ding][:name],
		      	:ding_typ => @ding.ding_typ,
		      	:published => @ding.published
		      	).first_or_create
		  elsif params[:ding].has_key?(:ding_typ_id)
	      	if @ding.ding_typ_id == params[:ding][:ding_typ_id].to_i
	      		return
	      	end
		      @new_ding = Ding.where(
		      	:name => @ding.name,
		      	:ding_typ => params[:ding][:ding_typ_id].to_i,
		      	:published => @ding.published
		      	).first_or_create
		  end
	      # take all assoziationen which contain that ding
	      @all_asses_1 = Assoziation
	      	.joins(:user_assoziations)
	      	.where(:ding_eins_id => @ding.id)
	      	.where(:user_assoziations => {:user_id => current_user.id})
	      @all_asses_1.each do |ass|
	      	attrib = ass.dup.attributes
	      	attrib[:ding_eins_id] = @new_ding.id
	      	@new_ass = Assoziation.find_or_create_by({:ding_eins_id => @new_ding.id, :ding_zwei_id => ass.ding_zwei_id})
	      	# if user has already associated the new one, don't recreate it; just delete the old obsolete assoziation
	      	if UserAssoziation.where(
				:user_id => current_user.id).where(
				:assoziation_id => @new_ass.id).count > 0
				ass.delete
			else
		      	@user_ass = UserAssoziation.where(
					:user_id => current_user.id).where(
					:assoziation_id => ass.id).update_all(assoziation_id: @new_ass.id)
			end
	      end
	      @all_asses_2 = Assoziation
	      	.joins(:user_assoziations)
	      	.where(:ding_zwei_id => @ding.id)
	      	.where(:user_assoziations => {:user_id => current_user.id})
	      @all_asses_2.each do |ass|
	      	@new_ass = Assoziation.find_or_create_by({:ding_eins_id => ass.ding_eins_id, :ding_zwei_id => @new_ding.id})
	      	
	      	# if user has already associated the new one, don't recreate it; just delete the old obsolete assoziation
	      	if UserAssoziation.where(
				:user_id => current_user.id).where(
				:assoziation_id => @new_ass.id).count > 0
				ass.delete
			else
		      	@user_ass = UserAssoziation.where(
					:user_id => current_user.id).where(
					:assoziation_id => ass.id).update_all(assoziation_id: @new_ass.id)
			end
	      end
	      
	      format.html { redirect_to(@new_ding, :notice => 'Ding was successfully updated.') }
	      format.json { respond_with_bip(@ding) }
	    end
	  end
	end
end
