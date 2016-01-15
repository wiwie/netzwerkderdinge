class DingsController < ApplicationController
	before_action :authenticate_user!
	autocomplete :ding, :name
	
	def index
		@dings = Ding.all()

		st = ActiveRecord::Base.connection
		@pop_dings = st.execute('SELECT ding_id,SUM(count) count FROM
				(SELECT ding_eins_id ding_id,count(*) as count 
				FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
				GROUP BY ding_eins_id
				UNION
				SELECT ding_zwei_id ding_id,count(*) as count 
				FROM assoziations ass JOIN user_assoziations ua ON (ass.id=ua.assoziation_id)
				GROUP BY ding_zwei_id)
				GROUP BY ding_id
				ORDER BY count DESC LIMIT 10;')
		st.close()

		@newest_dings = Ding.order("created_at DESC").limit(10)

		@all_dings = Ding.with_translations.order("name").paginate(:page => params[:page], :per_page => 10)
	end


	def autocomplete_ding_name
		term = params[:term]
		query = 'SELECT dings.id,ding_translations.name FROM dings JOIN ding_translations
			ON (dings.id=ding_translations.ding_id)
			WHERE ding_translations.locale = "' + params[:locale] + '" 
			AND ding_translations.name LIKE "' + term + '%"
			ORDER BY ding_translations.name'
		puts query
		dings = Ding.connection.select_all(query)
		render :json => dings.map { |ding| {:id => ding["id"], :label => ding["name"], :value => ding["name"]} }
	end

	def has_translation(ding_id, attribute, locale)
		@ding = Ding.find(ding_id)
		puts @ding[attribute.to_s + "_" + locale]
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

		#potential new assoziation
		@assoziation = Assoziation.new
	end

	def new
		@ding = Ding.new
	end

	def create
		@ding = Ding.new(params.require(:ding).permit(:name, :ding_typ_id))

		if not @ding.ding_typ
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
		elsif params[:ding].has_key?(:ding_typ_id)
	  	  if @ding.update_attribute(:ding_typ_id, params[:ding][:ding_typ_id].to_i)
		    format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
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
