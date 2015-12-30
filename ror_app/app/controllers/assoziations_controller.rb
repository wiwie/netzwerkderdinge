class AssoziationsController < ApplicationController

	def new
		if params.has_key?(:ding_eins_id) and params.has_key?(:selected_ding_id)
			@id_eins = params[:ding_eins_id]
			@id_zwei = params[:selected_ding_id]

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
		@asses = Assoziation.all()
	end

	def show
		@ass = Assoziation.find(params[:id])
	end
end
