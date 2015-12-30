class DingsController < ApplicationController
	before_action :authenticate_user!
	autocomplete :ding, :name
	
	def index
		@dings = Ding.all()
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
		@ding = Ding.new(params.require(:ding).permit(:name))

		@ding.save()
		redirect_to @ding
	end
end
