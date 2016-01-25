class DingHasTypsController < ApplicationController

	# we cannot just update the existing ding; because others may have associated it.
	def update
	  @ding_has_typ = DingHasTyp.find params[:id]
	  @ding = @ding_has_typ.ding

	  respond_to do |format|
		if params[:ding_has_typ].has_key?(:ding_typ_id)
	  	  if @ding_has_typ.update_attribute(:ding_typ_id, params[:ding_has_typ][:ding_typ_id].to_i)
		    @ding.save
		    format.html { redirect_to(@ding, :notice => 'User was successfully updated.') }
		    format.json { respond_with_bip(@ding_has_typ) }
		  end
		end
	end
	end
end
