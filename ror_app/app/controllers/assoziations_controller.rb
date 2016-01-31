class AssoziationsController < ApplicationController
	before_action :authenticate_user!

	def new
		if params.has_key?(:ding_eins_id) and params.has_key?(:selected_ding_zwei_id)
			@id_eins = params[:ding_eins_id].to_i
			ding = Ding.find(@id_eins)

			ding.update_attribute(
				:published,
				ding.published ? true : params["user_assoziation"]["published"] == "1"
			)

			if params[:selected_ding_zwei_id] == ''
				ding = Ding.where(:name => params[:assoziation][:ding_zwei_id]).first
				if not ding
					ding = Ding.where(:name => params[:assoziation][:ding_zwei_id]).create
					DingHasTyp.create(
						:ding => ding, 
						:user => current_user,
						:ding_typ => ding.guess_ding_typ_from_name)
				end
				ding.update_attribute(
					:published,
					ding.published ? true : params["user_assoziation"]["published"] == "1"
				)
				@id_zwei = ding.id
			else
				@id_zwei = params[:selected_ding_zwei_id].to_i
			end

			@first_ass = Assoziation.where(ding_eins_id: @id_eins, ding_zwei_id: @id_zwei).first_or_create
			@first_ass.save()

			@first_user_ass = UserAssoziation.where(:assoziation_id => @first_ass.id, :user => current_user).first_or_create
			@first_user_ass.update_attribute(:published, params["user_assoziation"]["published"] == "1")

			# we change the default to creating the assoziations symmetricely;
			if not params.has_key?(:assoziation) or not params[:assoziation].has_key?(:symmetric) or params[:assoziation][:symmetric] == '1'
				@snd_ass = Assoziation.where(:ding_eins_id => @id_zwei,
					:ding_zwei_id => @id_eins).first_or_create
				@snd_ass.save()

				@snd_user_ass = UserAssoziation.new(:assoziation => @snd_ass, :user => current_user, :published => params["user_assoziation"]["published"] == "1")
				@snd_user_ass.save()
			end

			redirect_to @first_user_ass
		else
			@assoziation = Assoziation.new()
		end
	end

	def create
		if not params.has_key?(:selected_ding_eins_id) or params[:selected_ding_eins_id] == ''
			@ding = Ding.where(:name => params[:assoziation][:ding_eins_id]).first
			if not @ding
				@ding = Ding.where(:name => params[:assoziation][:ding_eins_id]).create
				DingHasTyp.create(
					:ding => @ding, 
					:user => current_user,
					:ding_typ => @ding.guess_ding_typ_from_name)
			end
			@ding.update_attribute(:published,@ding.published ? true : params["user_assoziation"]["published"] == "1")
			ding_eins_id = @ding.id
		else
			ding_eins_id = params[:selected_ding_eins_id].to_i
		end

		if not params.has_key?(:selected_ding_zwei_id) or params[:selected_ding_zwei_id] == ''
			@ding = Ding.where(:name => params[:assoziation][:ding_zwei_id]).first
			if not @ding
				@ding = Ding.where(:name => params[:assoziation][:ding_zwei_id]).create
				DingHasTyp.create(
					:ding => @ding, 
					:user => current_user,
					:ding_typ => @ding.guess_ding_typ_from_name)
			end
			@ding.update_attribute(:published,@ding.published ? true : params["user_assoziation"]["published"] == "1")
			ding_zwei_id = @ding.id
		else
			ding_zwei_id = params[:selected_ding_zwei_id].to_i
		end

		@first_ass = Assoziation.where(:ding_eins_id => ding_eins_id,
			:ding_zwei_id => ding_zwei_id).first_or_create
		@first_ass.save()

		@first_user_ass = UserAssoziation.new(:assoziation => @first_ass, :user => current_user, :published => params["user_assoziation"]["published"] == "1")
		@first_user_ass.save()

		# we change the default to creating the assoziations symmetricely;
		if not params.has_key?(:assoziation) or not params[:assoziation].has_key?(:symmetric) or params[:assoziation][:symmetric] == '1'
			@snd_ass = Assoziation.where(:ding_eins_id => ding_zwei_id,
				:ding_zwei_id => ding_eins_id).first_or_create
			@snd_ass.save()

			@snd_user_ass = UserAssoziation.new(:assoziation => @snd_ass, :user => current_user, :published => params["user_assoziation"]["published"] == "1")
			@snd_user_ass.save()
		end

		redirect_to @first_user_ass
	end

	def create_for_current_user
		@ass = Assoziation.find(params[:assoziation_id])
		@userass = UserAssoziation.where(:assoziation_id => @ass.id, :user_id => current_user.id).first_or_create
		redirect_to @userass
	end

	def remove_for_current_user
		@ass = Assoziation.find(params[:assoziation_id])
		@userass = UserAssoziation.where(:assoziation_id => @ass.id, :user_id => current_user.id).destroy_all
		redirect_to url_for([current_user, UserAssoziation])
	end

	def index
		#show associations of specific user
		if params.has_key?(:user_id)
			@asses = UserAssoziation.where(:user_id => params[:user_id]).where(:published => true).order('created_at desc').limit(10)
			@new_asses = current_user.get_new_associations(params[:user_id]).take(10)
			@new_unknown_asses = current_user.get_new_associations(params[:user_id], 'created_at').take(10)
		#show associations of all users
		else
			@asses = UserAssoziation.where(:published => true).order('created_at desc').limit(10)
			@pop_asses = Assoziation.group(:ding_eins_id, :ding_zwei_id).first(10)
			@new_asses = current_user.get_new_associations().take(10)
			@new_unknown_asses = current_user.get_new_associations(nil, 'created_at').take(10)

			@all_asses = Assoziation.includes(:ding_eins => :translations, :ding_zwei => :translations)
			.order("ding_translations.name, translations_dings.name")
			.paginate(:page => params[:page], :per_page => 10)
		end
	end

	def show
		@ass = Assoziation.find(params[:id])
	end
end
