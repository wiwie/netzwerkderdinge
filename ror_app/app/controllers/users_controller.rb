class UsersController < ApplicationController
	def agreements
		@agree = current_user.get_agreement.sort_by{|k, v| v}.reverse
	end
end
