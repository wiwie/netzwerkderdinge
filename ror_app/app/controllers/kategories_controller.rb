class KategoriesController < ApplicationController
	before_action :authenticate_user!
	autocomplete :kategorie, :name

	def index
		@kats = Kategorie.all
	end

	def show
		@kat = Kategorie.find(params[:id])
	end
	
	def new
		@kat = Kategorie.new
	end

	def create
		@kat = Kategorie.new(params.require(:kategorie).permit(:name))

		@kat.save()
		redirect_to @kat
	end
end
