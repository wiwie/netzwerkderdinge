class Ding < ActiveRecord::Base
	has_many :assoziations, :foreign_key => 'ding_eins_id'
	has_many :eingehende_assoziations, :foreign_key => 'ding_zwei_id'
	#has_many :assoziierte_dinge, through: :assoziation, :source => 'ding_zwei'
	belongs_to :kategorie
	belongs_to :ding_typ
	has_many :ding_has_typs
	translates :name, :description
	globalize_accessors
	before_validation :after_initialize, on: :create

	def has_translation(attribute, locale)
		return self.send(attribute.to_s + '_' + locale.to_s)
	end

	def assoziierte_dinge(user)
		hash = Hash[*Assoziation.joins(:user_assoziations).where(
			:ding_eins_id => self.id).where(
			'user_assoziations.published = ? OR user_assoziations.user_id = ?', true, user.id).map{ 
				|ass| [ass.ding_zwei_id, ass] }.flatten].sort_by {|x| [-x[1].user_assoziations.count, Ding.find(x[0]).name.nil? ? '' : Ding.find(x[0]).name.downcase] }
		puts hash
		return hash
	end

	def get_symbol(user)
		ding_typ = self.ding_typ(user)
		if not ding_typ
			# skip this if
		elsif ding_typ.name == "Image"
			return "picture-o"
		elsif ding_typ.name == "Video"
			return "film"
		elsif ding_typ.name == "URL"
			return "external-link"
		elsif ding_typ.name == "Quote"
			return "quote-right"
		elsif ding_typ.name == "Todo List"
			return "tasks"
		elsif ding_typ.name == "Todo List Done"
			return "check-circle-o"
		elsif ding_typ.name == "Todo"
			return "circle-o"
		elsif ding_typ.name == "Todo Done"
			return "check-circle-o"
		end
		
		return "cube"
	end

	def self.search(search, user)
	  if search
	    with_translations.joins(:assoziations => :user_assoziations).where('name LIKE ?', "%#{search}%")
	    	.where("dings.published = 't' OR user_assoziations.user_id = ?", user.id).distinct
	  else
	    with_translations.joins(:assoziations => :user_assoziations)
	    	.where("dings.published = 't' OR user_assoziations.user_id = ?", user.id).distinct
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

	def guess_ding_typ_from_name
		begin
			if name.start_with? 'http://' or name.start_with? 'https://'
				if name.includes?('youtube')
					return DingTyp.find_by_name('Video')
				end
				url = URI.parse(name)
			    http_o = Net::HTTP.new(url.host, url.port)
		    	http_o.use_ssl = true if name.start_with? 'https://'
		    	http_o.start do |http|
			    	if http.head(url.request_uri)['Content-Type'].start_with? 'image'
			    		return DingTyp.find_by_name('Image')
			    	elsif http.head(url.request_uri)['Content-Type'].start_with? 'video'
			    		return DingTyp.find_by_name('Video')
			    	end
			    end
			    return DingTyp.find_by_name('URL')
			elsif name.start_with? '"' and name.end_with? '"'
				return DingTyp.find_by_name('Quote')
			end
		rescue
		end
		return DingTyp.find_by_name('Ding')
	end

	def after_initialize
		puts "after_initialize"
		if not ding_typ
			puts "after_initialize 2"
			write_attribute(:ding_typ_id, self.guess_ding_typ_from_name.id)
		end
	end

	def ding_typ(user=nil)
		if not user
			return DingTyp.find_by_name('Ding')
		else
			#return has_ding_typs#.where(:user => user).first
			@typs = DingHasTyp.where(:user => user, :ding => self)
			if @typs.count > 0
				return @typs.first.ding_typ
			end
			return DingTyp.find_by_name('Ding')
		end
	end
end
