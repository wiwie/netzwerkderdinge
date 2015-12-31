class AssoziationsController < ApplicationController

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

			@ass = Assoziation.where(ding_eins_id: @id_eins, ding_zwei_id: @id_zwei, user: current_user).first_or_create
			redirect_to @ass
		else
			@assoziation = Assoziation.new()
		end
	end

	def index
		@asses = Assoziation.group(:ding_eins_id, :ding_zwei_id).order('count_id desc').count('id')
	end

	def show
		@ass = Assoziation.find(params[:id])
	end

	def create
		if not params.has_key?(:selected_ding_eins_id) or params[:selected_ding_eins_id] == ''
			@ding = Ding.create(params[:assoziation][:ding_eins_id])
			ding_eins_id = @ding.id
		else
			ding_eins_id = params[:selected_ding_eins_id].to_i
		end

		if not params.has_key?(:selected_ding_zwei_id) or params[:selected_ding_zwei_id] == ''
			@ding = Ding.create(params[:assoziation][:ding_zwei_id])
			ding_zwei_id = @ding.id
		else
			ding_zwei_id = params[:selected_ding_zwei_id].to_i
		end

		@ding = Assoziation.new(:ding_eins_id => ding_eins_id,
			:ding_zwei_id => ding_zwei_id, user: current_user)

		@ding.save()
		redirect_to @ding
	end
end
