class Assoziation < ActiveRecord::Base
	belongs_to :ding_eins, :class_name => 'Ding', :foreign_key => 'ding_eins_id'
	belongs_to :ding_zwei, :class_name => 'Ding', :foreign_key => 'ding_zwei_id'
	has_many :user_assoziations

	#before_validation :handle_ding_ids, on: :create

	def count
		return UserAssoziation.where(:assoziation_id => self.id).count
	end
	
	#private
	#def handle_ding_ids
	#	if self.ding_eins_id > self.ding_zwei_id
	#		tmp = self.ding_eins_id
	#		self.ding_eins_id = self.ding_zwei_id
	#		self.ding_zwei_id = tmp
	#	end
	#end

end
