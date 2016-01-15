class SearchsController < ApplicationController
	def index
		if params.has_key?(:search)
			@found_dings = Ding.search(params[:search]).paginate(:page => params[:page], :per_page => 10)
		end
	end
end
