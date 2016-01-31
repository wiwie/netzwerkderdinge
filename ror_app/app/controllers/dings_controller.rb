require 'rmagick'

class DingsController < ApplicationController
	before_action :authenticate_user!
	autocomplete :ding, :name
	
	def index
		st = ActiveRecord::Base.connection
		#@pop_dings = st.execute('SELECT ding_id,SUM(count) count FROM
		#		(SELECT ding_eins_id ding_id,count(*) as count 
		#		FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
		#		WHERE published = "t"
		#		GROUP BY ding_eins_id
		#		UNION
		#		SELECT ding_zwei_id ding_id,count(*) as count 
		#		FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
		#		WHERE published = "t"
		#		GROUP BY ding_zwei_id)
		#		GROUP BY ding_id
		#		ORDER BY count DESC LIMIT 10;')
		@pop_dings = st.execute('SELECT ding_id,SUM(count) count FROM
				(SELECT ding_eins_id ding_id,count(*) as count 
				FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
				WHERE published = "t"
				GROUP BY ding_eins_id)
				GROUP BY ding_id
				ORDER BY count DESC LIMIT 10;')
		st.close()

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

		render :json => dings.map { |ding| {:id => ding["id"], :label => ding["name"], :value => ding["name"]} }
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
		@ding = Ding.find(params[:id])

		# make sure, that the current user is allowed to show this ding;
		# if it is non-published, the user needs to have at least one assoziation to it;
		@users = UserAssoziation.where(:assoziation_id => Assoziation.where('ding_eins_id = ? OR ding_zwei_id = ?', @ding.id, @ding.id)).select(:user_id).distinct.collect {|x| x.user_id}
		@can_access = @ding.published || (@users.include?(current_user.id))
		
		if @can_access
			@has_ding_typ = @ding.ding_has_typs.where(:user => current_user).first
			if not @has_ding_typ
				@has_ding_typ = DingHasTyp.create(:ding => @ding, :user => current_user, :ding_typ => DingTyp.find_by_name('Ding'))
			end
			@ding_typ = @has_ding_typ.ding_typ

			if @ding_typ.name == 'URL'
				begin
					@page_preview = LinkThumbnailer.generate(@ding.name)
				rescue
				end
			elsif @ding_typ.name == 'Todo List' or @ding_typ.name == 'Todo List Done'
				@todos = @ding.assoziierte_dinge(current_user).select {|d| Ding.find(d[0]).ding_typ(current_user).name == 'Todo' or Ding.find(d[0]).ding_typ(current_user).name == 'Todo List' }
				@done_todos = @ding.assoziierte_dinge(current_user).select {|d| Ding.find(d[0]).ding_typ(current_user).name == 'Todo Done' or Ding.find(d[0]).ding_typ(current_user).name == 'Todo List Done' }
		  		if @todos.count+@done_todos.count > 0
					@perc_finished = (@done_todos.count.to_f/(@todos.count+@done_todos.count)*100).to_i
				end
				@sublistof = Assoziation.joins(:user_assoziations, 
						:ding_eins => {:ding_has_typs => :ding_typ})
					.where(:ding_zwei => @ding)
					.where('ding_typs.name = ? OR ding_typs.name = ?', 'Todo List', 'Todo List Done')
			elsif @ding_typ.name == 'Todo' or @ding_typ.name == 'Todo Done'
				@todoof = Assoziation.joins(:user_assoziations,
						:ding_eins => {:ding_has_typs => :ding_typ})
					.where(:ding_zwei => @ding)
					.where('ding_typs.name = ? OR ding_typs.name = ?', 'Todo List', 'Todo List Done')
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
		@ding = Ding.find(params[:ding_id])
		file = Tempfile.new('foo')

	    @@r.myplot.call(file.path, @ding.description.nil? ? '' : @ding.description)

	    send_file file, :type => "image/png", :disposition => "inline"
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
		    format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
		  end
		elsif params[:ding].has_key?(:description)
	  	  if @ding.update_attribute(:description, params[:ding][:description])
		    format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
		  end
		elsif params[:ding].has_key?(:published)
			@success = false
			#if we are unpublishing, make assoziationen consistent
			if params[:ding][:published] == 'false'
				# make sure that all assoziationen are from the current user (should be the case)
				@userasses = UserAssoziation.where(:assoziation_id => Assoziation.where('ding_eins_id = ? OR ding_zwei_id = ?', @ding.id, @ding.id))
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
					format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
					format.json { respond_with_bip(@ding) }
				end
			end
	    else
	      @new_ding = Ding.where(:name => params[:ding][:name]).first_or_create
	      # take all assoziationen which contain that ding
	      @all_asses_1 = Assoziation.joins(:user_assoziations).where(:ding_eins_id => @ding.id).where(:user_assoziations => {:user_id => current_user.id})
	      @all_asses_1.each do |ass|
	      	attrib = ass.dup.attributes
	      	attrib[:ding_eins_id] = @new_ding.id
	      	if ass.ding_zwei_id > @new_ding.id
	      		@new_ass = Assoziation.find_or_create_by({:ding_eins_id => @new_ding.id, :ding_zwei_id => ass.ding_zwei_id})
	      	else
	      		@new_ass = Assoziation.find_or_create_by({:ding_eins_id => ass.ding_zwei_id, :ding_zwei_id => @new_ding.id})
	      	end

	      	@user_ass = UserAssoziation.where(
				:user_id => current_user.id).where(
				:assoziation_id => ass.id)
			@new_user_ass = UserAssoziation.find_or_create_by(
				:user_id => current_user.id, 
				:assoziation_id => @new_ass.id)
			@user_ass.destroy_all
	      end
	      @all_asses_2 = Assoziation.joins(:user_assoziations).where(:ding_zwei_id => @ding.id).where(:user_assoziations => {:user_id => current_user.id})
	      @all_asses_2.each do |ass|
	      	if ass.ding_eins_id > @new_ding.id
	      		@new_ass = Assoziation.find_or_create_by({:ding_eins_id => @new_ding.id, :ding_zwei_id => ass.ding_eins_id})
	      	else
	      		@new_ass = Assoziation.find_or_create_by({:ding_eins_id => ass.ding_eins_id, :ding_zwei_id => @new_ding.id})
	      	end

	      	@user_ass = UserAssoziation.where(
				:user_id => current_user.id).where(
				:assoziation_id => ass.id)
			@new_user_ass = UserAssoziation.find_or_create_by(
				:user_id => current_user.id, 
				:assoziation_id => @new_ass.id)
			@user_ass.destroy_all
	      end

	      #.update_all(:assoziation_id => @new_ding.id)
	      format.html { redirect_to(@new_ding, :notice => 'User was successfully updated.') }
	      format.json { respond_with_bip(@ding) }
	    end
	  end
	end
end
