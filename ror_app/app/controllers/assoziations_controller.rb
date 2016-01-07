class AssoziationsController < ApplicationController
	before_action :authenticate_user!

	def new
		if params.has_key?(:ding_eins_id) and params.has_key?(:selected_ding_zwei_id)
			@id_eins = params[:ding_eins_id].to_i
			if params[:selected_ding_zwei_id] == ''
				ding = Ding.create(:name => params[:assoziation][:ding_zwei_id])
				@id_zwei = ding.id
			else
				@id_zwei = params[:selected_ding_zwei_id].to_i
			end

			if @id_eins > @id_zwei
				tmp = @id_eins
				@id_eins = @id_zwei
				@id_zwei = tmp
			end
			@ass = Assoziation.where(ding_eins_id: @id_eins, ding_zwei_id: @id_zwei).first_or_create

			@ass.save()

			@user_ass = UserAssoziation.where(:assoziation_id => @ass.id, :user => current_user).first_or_create
			redirect_to @user_ass
		else
			@assoziation = Assoziation.new()
		end
	end

	def create
		if not params.has_key?(:selected_ding_eins_id) or params[:selected_ding_eins_id] == ''
			@ding = Ding.create(:name => params[:assoziation][:ding_eins_id])
			ding_eins_id = @ding.id
		else
			ding_eins_id = params[:selected_ding_eins_id].to_i
		end

		if not params.has_key?(:selected_ding_zwei_id) or params[:selected_ding_zwei_id] == ''
			@ding = Ding.create(:name => params[:assoziation][:ding_zwei_id])
			ding_zwei_id = @ding.id
		else
			ding_zwei_id = params[:selected_ding_zwei_id].to_i
		end

		@ass = Assoziation.where(:ding_eins_id => ding_eins_id,
			:ding_zwei_id => ding_zwei_id).first_or_create

		@ass.save()

		@user_ass = UserAssoziation.new(:assoziation_id => @ass.id, :user => current_user)
		@user_ass.save()

		redirect_to @user_ass
	end

	def create_for_current_user
		@ass = Assoziation.find(params[:assoziation_id])
		@userass = UserAssoziation.where(:assoziation_id => @ass.id, :user_id => current_user.id).first_or_create
		redirect_to @userass
	end

	def index
		#show associations of specific user
		if params.has_key?(:user_id)
			@asses = UserAssoziation.where(:user_id => params[:user_id]).order('created_at desc').limit(10)
			@new_asses = current_user.get_new_associations(params[:user_id]).take(10)
			@new_unknown_asses = current_user.get_new_associations(params[:user_id], 'created_at').take(10)
		#show associations of all users
		else
			@asses = UserAssoziation.order('created_at desc').limit(10)
			@pop_asses = Assoziation.group(:ding_eins_id, :ding_zwei_id).first(10)
			@new_asses = current_user.get_new_associations().take(10)
			@new_unknown_asses = current_user.get_new_associations(nil, 'created_at').take(10)
		end
	end

	def show
		@ass = Assoziation.find(params[:id])
	end
end
