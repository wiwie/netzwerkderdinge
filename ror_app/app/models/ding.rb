class Ding < ActiveRecord::Base
	has_many :assoziations, :foreign_key => 'ding_eins_id'
	has_many :eingehende_assoziations, :class_name => 'Assoziation', :foreign_key => 'ding_zwei_id'
	has_many :ding_has_typs
	has_many :favorits, :dependent => :delete_all
	#has_many :assoziierte_dinge, through: :assoziation, :source => 'ding_zwei'
	belongs_to :kategorie
	belongs_to :ding_typ
	translates :name, :description
	globalize_accessors
	before_validation :after_initialize, on: :create

	def has_translation(attribute, locale)
		return self.send(attribute.to_s + '_' + locale.to_s)
	end

	def assoziierte_dinge(user)
		hash = Hash[*Assoziation.joins({:ding_eins => :ding_typ}, {:ding_zwei => :ding_typ}, :user_assoziations).where(
			:ding_eins_id => self.id).where(
			'user_assoziations.published = ? OR user_assoziations.user_id = ?', true, user.id).map{ 
				|ass| [ass.ding_zwei, ass] }.flatten].sort_by {|x| [-x[1].user_assoziations.count, x[0].name.nil? ? '' : x[0].name.downcase] }
		return hash
	end

	def get_symbol
		return Ding.get_symbol(self.ding_typ)
	end

	def self.get_symbol(ding_typ)
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
			return "check"
		elsif ding_typ.name == "Todo Skip"
			return "pause"
		elsif ding_typ.name == "Todo Fail"
			return "times"
		elsif ding_typ.name == "Habit"
			return "tachometer"
		elsif ding_typ.name == "Habit Collection"
			return "tachometer"
		elsif ding_typ.name == "Start Time Point"
			return "clock-o"
		elsif ding_typ.name == "Time Span"
			return "refresh"
		end
		
		return "cube"
	end

	def self.search(search, user)
	  if search
	    with_translations.joins(:assoziations => :user_assoziations, :eingehende_assoziations => :user_assoziations)
	    	.where("user_assoziations.user_id = ?", user.id)
	    	.where('name LIKE ?', "%#{search}%")
	    	.where("dings.published = 't'").distinct
	  else
	    with_translations.joins(:assoziations => :user_assoziations, :eingehende_assoziations => :user_assoziations)
	    	.where("user_assoziations.user_id = ?", user.id)
	    	.where("dings.published = 't'").distinct
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

	def self.guess_ding_typ_from_name(name)
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
		#if not ding_typ
			#write_attribute(:ding_typ_id, Ding.guess_ding_typ_from_name(self.name).id)
		#end
	end

	# TODO: what if we are no habit ding?
	def get_habit_info(current_user)
		@ding = self
		@starttp_ass = Assoziation
			.joins(:user_assoziations, :ding_zwei => :ding_typ)
			.where(:ding_eins => @ding)
			.where(:user_assoziations => {:user => current_user})
			.where("ding_typs.name = ?", 'Start Time Point')
		@has_starttp = @starttp_ass.count > 0
		if @has_starttp
			@starttp_ding = @starttp_ass.first.ding_zwei
		else
			return nil
		end

		@timespan_ass = Assoziation
			.joins(:user_assoziations, :ding_zwei => :ding_typ)
			.where(:ding_eins => @ding)
			.where(:user_assoziations => {:user => current_user})
			.where("ding_typs.name = ?", 'Time Span')
		@has_timespan = @timespan_ass.count > 0
		if @has_timespan
			@timespan_ding = @timespan_ass.first.ding_zwei
		else
			return nil
		end

		if @timespan_ding.name.end_with?(" hour")
			@ts = @timespan_ding.name.partition(" ").first.to_i.hours
		elsif @timespan_ding.name.end_with?(" day")
			@ts = @timespan_ding.name.partition(" ").first.to_i.days
		elsif @timespan_ding.name.end_with?(" week")
			@ts = @timespan_ding.name.partition(" ").first.to_i.weeks
		elsif @timespan_ding.name.end_with?(" month")
			@ts = @timespan_ding.name.partition(" ").first.to_i.months
		elsif @timespan_ding.name.end_with?(" year")
			@ts = @timespan_ding.name.partition(" ").first.to_i.years
		end

		@times_done = Assoziation
			.joins(:user_assoziations, :ding_zwei => :ding_typ)
			.where(:ding_eins => @ding)
			.where(:user_assoziations => {:user => current_user})
			.where("ding_typs.name = ? OR ding_typs.name = ? OR ding_typs.name = ?", 'Todo Done', 'Todo Skip', 'Todo Fail')

		@times_done = @times_done.sort_by {|x| x.ding_zwei.name}

		@last_months = []
		@month = []
		@week = []

		@streak = 0

		begin
			if @starttp_ding and @ts
				latest_date_done = nil
				current_week = Time.parse(@starttp_ding.name)
				if current_week < Date.today-90.day
					current_week += ((Date.today-90.day-current_week)/@ts.to_f).ceil*@ts
				end
				
				current_day_ass_ind = -1
				if @times_done.count > 0
					current_day_ass_ind = 0
					current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
				end
				 	
				while current_week+@ts < Time.now

					while @times_done.count > 0 and current_date_ass < current_week and current_day_ass_ind < @times_done.count-1
						current_day_ass_ind += 1
						current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
					end

					if @times_done.count > 0 and current_date_ass >= current_week and current_date_ass < current_week+@ts
						@last_months.append([@times_done[current_day_ass_ind].ding_zwei.ding_typ.name, (current_week).to_s])
						latest_date_done = current_week+@ts
						@streak += 1
					else
						@last_months.append(["",current_week.to_s])
						@streak = 0
					end

					current_week += @ts
				end

				@last_months = [[@last_months]]
				
				@latest_time = latest_date_done
			end
			#end
		rescue
			@last_months = []
		end
		if not @latest_time
			@latest_time = Time.parse(@starttp_ding.name)
		end
		@overdue = (Time.now - @latest_time - @ts)
		@is_overdue = @overdue > 0


		return {
			is_overdue: @is_overdue, 
			overdue: @overdue, 
			ts: @ts, 
			latest_time: @latest_time, 
			streak: @streak,
			last_month: @last_months}
	end
end
