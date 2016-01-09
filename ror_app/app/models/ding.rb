class Ding < ActiveRecord::Base
	#has_many :assoziation, :foreign_key => 'ding_eins_id'
	#has_many :assoziierte_dinge, through: :assoziation, :source => 'ding_zwei'
	belongs_to :kategorie
	translates :name, :description
	globalize_accessors

	def has_translation(attribute, locale)
		return self.send(attribute.to_s + '_' + locale.to_s)
	end

	def assoziierte_dinge
		asses1 = Assoziation.where(:ding_eins_id => self.id).joins(:user_assoziations).group(:ding_zwei_id).count()
		asses2 = Assoziation.where(:ding_zwei_id => self.id).joins(:user_assoziations).group(:ding_eins_id).count()
		return asses1.merge(asses2).sort_by{|k, v| v}.reverse
	end
end
