class SearchsController < ApplicationController
	def index
		if params.has_key?(:search)
			@found_dings = Ding.search(params[:search], current_user).paginate(:page => params[:page], :per_page => 10)
		end
	end
end
