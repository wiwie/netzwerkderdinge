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

	def update
	  @ding = Ding.find params[:id]

	  respond_to do |format|
	  	if params[:ding].has_key?(:kategorie)
	  	  if @ding.update_attribute(:kategorie, Kategorie.find(params[:ding][:kategorie].to_i))
		    format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@ding) }
		  end
	    else @ding.update_attributes(params.require(:ding).permit(:name))
	      format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
	      format.json { respond_with_bip(@ding) }
	    end
	  end
	end
end
