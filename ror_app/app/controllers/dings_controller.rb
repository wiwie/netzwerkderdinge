class DingsController < ApplicationController
	before_action :authenticate_user!
	autocomplete :ding, :name
	
	def index
		@dings = Ding.all()

		st = ActiveRecord::Base.connection
		@pop_dings = st.execute('SELECT ass1.ding_id,ass1.count+ass2.count count FROM 
				(SELECT ding_eins_id ding_id,count(*) as count 
				FROM assoziations
				GROUP BY ding_eins_id ORDER BY count DESC ) ass1 JOIN
				(SELECT ding_zwei_id ding_id,count(*) as count 
				FROM assoziations
				GROUP BY ding_zwei_id ORDER BY count DESC ) ass2
				ON (ass1.ding_id=ass2.ding_id)
				ORDER BY count DESC LIMIT 10;')
		st.close()
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
