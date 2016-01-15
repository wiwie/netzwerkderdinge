class Ding < ActiveRecord::Base
	#has_many :assoziation, :foreign_key => 'ding_eins_id'
	#has_many :assoziierte_dinge, through: :assoziation, :source => 'ding_zwei'
	belongs_to :kategorie
	belongs_to :ding_typ
	translates :name, :description
	globalize_accessors

	def has_translation(attribute, locale)
		return self.send(attribute.to_s + '_' + locale.to_s)
	end

	def assoziierte_dinge
		asses1 = Hash[*Assoziation.where(
			:ding_eins_id => self.id).map{ |ass| [ass.ding_zwei_id, ass] }.flatten]
		asses2 = Hash[*Assoziation.where(
			:ding_zwei_id => self.id).map{ |ass| [ass.ding_eins_id, ass] }.flatten]
		merged = asses1.merge(asses2) {
			|key, val1, val2| val1 + val2
			}

		#return merged.sort_by {|x| Ding.with_translations(I18n.locale).find(x[0]).name}.reverse
		return merged.sort_by {|x| [-x[1].user_assoziations.count, Ding.find(x[0]).name.nil? ? '' : Ding.find(x[0]).name.downcase] }
		#Ding.with_translations(params[:locale])
		#sort = merged.sort do |x, y|
		#	comp = (x[1].user_assoziations.count <=> y[1].user_assoziations.count)
		#	comp.zero? ? (Ding.with_translations(I18n.locale).find(x[0]).name <=> Ding.with_translations(I18n.locale).find(y[0]).name) : comp
		#end
		#return sort.reverse
	end

	def get_symbol
		if self.ding_typ == DingTyp.find_by_name("Image")
			return "picture"
		elsif self.ding_typ == DingTyp.find_by_name("Video")
			return "film"
		elsif self.ding_typ == DingTyp.find_by_name("URL")
			return "new-window"
		else
			return "paperclip"
		end
	end

	def self.search(search)
	  if search
	    with_translations.where('name LIKE ?', "%#{search}%")
	  else
	    with_translations
	  end
	end

	def get_video_link
		if 'youtube'.in? self.name and 'watch'.in? self.name
			self.name[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
    		youtube_id = $5
			return 'https://youtube.com/embed/' + youtube_id
		else
			return self.name
		end
	end
end
