class UserAssoziationsController < ApplicationController
	before_action :authenticate_user!

	def show
		@userass = UserAssoziation.find(params[:id])
		if current_user == @userass.user
			@ass = @userass.assoziation
		end
	end

	def update
	  @userass = UserAssoziation.find params[:id]

	  respond_to do |format|
		if params[:user_assoziation].has_key?(:published)
	  	  if @userass.update_attribute(:published, params[:user_assoziation][:published])
		    format.html { redirect_to(@userass, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@userass) }
		  end
	  	else 
	  	  @userass.update_attributes(params.require(:user_assoziation).permit(:description))
	      format.html { redirect_to(@userass, :notice => 'User was successfully updated.') }
	      format.json { respond_with_bip(@userass) }
	    end
	  end
	end

	def destroy
		@userass = UserAssoziation.find params[:id]
		if @userass.user == current_user
			@userass.destroy
			redirect_to(url_for(Assoziation), :notice => 'Association was successfully deleted.')
		end
	end

	def index
		@all_asses = current_user.user_assoziations.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
	end
end
