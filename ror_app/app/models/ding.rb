class Ding < ActiveRecord::Base
	#has_many :assoziation, :foreign_key => 'ding_eins_id'
	#has_many :assoziierte_dinge, through: :assoziation, :source => 'ding_zwei'

	def assoziierte_dinge
		asses1 = Assoziation.where(:ding_eins_id => self.id).group(:ding_zwei_id).count()
		asses2 = Assoziation.where(:ding_zwei_id => self.id).group(:ding_eins_id).count()
		return asses1.merge(asses2)
	end
end
