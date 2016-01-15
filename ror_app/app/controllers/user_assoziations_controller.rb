class UserAssoziationsController < ApplicationController
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
			# TODO
			@ass = Assoziation.where(ding_eins_id: @id_eins, ding_zwei_id: @id_zwei, user: current_user).first_or_create
			redirect_to @ass
		else
			@assoziation = Assoziation.new()
		end
	end

	def show
		@userass = UserAssoziation.find(params[:id])
		if current_user == @userass.user
			@ass = @userass.assoziation
		end
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

		@ass = Assoziation.where(:ding_eins_id => ding_eins_id,
			:ding_zwei_id => ding_zwei_id).first_or_create

		@ass.save()

		@user_ass = UserAssoziation.new(:assoziation => @ass, :user => current_user)
		@user_ass.save()

		redirect_to @ass
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
