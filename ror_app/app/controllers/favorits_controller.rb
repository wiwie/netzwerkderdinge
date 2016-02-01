class FavoritsController < ApplicationController
	def index
		@favorits = current_user.favorits

		@ding_ids = current_user.favorits.select(:ding_id).collect { |a| a.ding_id	}
		@favorit_asses = current_user.user_assoziations
			.joins(:assoziation)
			.where("assoziations.ding_eins_id IN (?) OR assoziations.ding_zwei_id IN (?)", @ding_ids, @ding_ids)

		#potential new  favorit
		@favorit = Favorit.new(:user => current_user)
	end

	def new
		@favorit = Favorit.new
	end

	def create
		if not params.has_key?(:selected_ding_id) or params[:selected_ding_id] == ''
			name = params[:favorit][:ding_id]
			guessed_ding_typ = Ding.guess_ding_typ_from_name(name)

			@ding = Ding.where(:name => name).where(:ding_typ => guessed_ding_typ).first_or_create
		else
			@ding = Ding.find(params[:selected_ding_id].to_i)
		end

		@fav = Favorit.where(:user => current_user, :ding => @ding).first_or_create
		
		redirect_to user_favorits_path(@fav)
	end

	def create_for_current_user
		@ding = Ding.find(params[:ding_id])
		Favorit.where(:ding_id => @ding.id, :user_id => current_user.id).first_or_create
		redirect_to @ding
	end

	def remove_for_current_user
		@ding = Ding.find(params[:ding_id])
		Favorit.where(:ding_id => @ding.id, :user_id => current_user.id).destroy_all
		redirect_to @ding
	end
end
