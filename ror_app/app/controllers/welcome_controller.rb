class WelcomeController < ApplicationController
	def index
		@newest_asses = Assoziation.limit(10).order('created_at DESC')
		@pop_asses = Assoziation.group(:ding_eins_id, :ding_zwei_id).order('count_id desc').count('id').first(10)
	end
end
