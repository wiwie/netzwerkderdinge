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

	trigger.name(:trigger_increase_indegree).after(:insert) do
		"UPDATE dings SET indegree = indegree + 1 WHERE id = NEW.ding_zwei_id;"
	end

	trigger.name(:trigger_increase_outdegree).after(:insert) do
		"UPDATE dings SET outdegree = outdegree + 1 WHERE id = NEW.ding_eins_id;"
	end

	trigger.name(:trigger_decrease_indegree).after(:delete) do
		"UPDATE dings SET indegree = indegree - 1 WHERE id = OLD.ding_zwei_id;"
	end

	trigger.name(:trigger_decrease_oudegree).after(:delete) do
		"UPDATE dings SET outdegree = outdegree - 1 WHERE id = OLD.ding_eins_id;"
	end

end
