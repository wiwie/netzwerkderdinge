class FavoritsController < ApplicationController
	def index
		@favorits = current_user.favorits

		#potential new  favorit
		@favorit = Favorit.new(:user => current_user)
	end

	def new
		@favorit = Favorit.new
	end

	def create
		if not params.has_key?(:selected_ding_id) or params[:selected_ding_id] == ''
			@ding = Ding.where(:name => params[:favorit][:ding_id]).first_or_create
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