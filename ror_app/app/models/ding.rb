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

		@has_latest = @times_done.count > 0
		if @has_latest
			@latest_ding = @times_done.last.ding_zwei
		else
			@latest_ding = @starttp_ding
		end
		begin
			if @latest_ding.name.include? ':'
				@latest_time = Time.strptime(@latest_ding.name, "%Y/%m/%d %H:%M")
			else
				@latest_time = Time.strptime(@latest_ding.name, "%Y/%m/%d")
			end
		rescue
			return nil
		end

		@overdue = (Time.now - @latest_time - @ts)
		@is_overdue = @overdue > 0

		# how many times have we done the habit in time?
		@streak = 0
		comp_time = Time.now

		@times_done_rev = @times_done.reverse

		@times_done_rev.each do |ass|
			if ass.ding_zwei.ding_typ.name == 'Todo Fail'
				break
			end

			begin
				if ass.ding_zwei.name.include? ':'
					next_time = Time.strptime(ass.ding_zwei.name, "%Y/%m/%d %H:%M")
				else
					next_time = Time.strptime(ass.ding_zwei.name, "%Y/%m/%d")
				end
			rescue
				next
			end
			time_diff = comp_time - next_time
			if time_diff > @ts
				break
			end
			comp_time = next_time
			@streak += 1
		end

		@last_months = []
		@month = []
		@week = []

		# if its daily, show the last three months
		# if @timespan_ding.name.end_with?(" day")
		# 	current_day = Date.today
		# 	current_day_ass_ind = @times_done.count-1
		# 	current_date_ass = Date.parse(@times_done[current_day_ass_ind].ding_zwei.name)
			 	
		# 	while current_day > (Date.today-90.day)
		# 		if current_day.wday == 0
		# 			@month.append(@week)
		# 			@week = []
		# 		end

		# 		if current_day.day == 1
		# 			@last_months.append(@month)
		# 			@month = []
		# 		end

		# 		while current_date_ass > current_day and current_day_ass_ind > 0
		# 			current_day_ass_ind -= 1
		# 			current_date_ass = Date.parse(@times_done[current_day_ass_ind].ding_zwei.name)
		# 		end

		# 		if current_date_ass == current_day
		# 			@week.unshift([@times_done[current_day_ass_ind].ding_zwei.ding_typ.name,current_day.to_s])
		# 		else
		# 			@week.unshift(["",current_day.to_s])
		# 		end

		# 		current_day -= @ts
		# 	end
		# elsif @timespan_ding.name.end_with?(" week")
			current_week = Time.parse(@starttp_ding.name)
			if current_week < Date.today-90.day
				current_week += ((Date.today-90.day-current_week)/@ts.to_f).ceil*@ts
			end
			
			current_day_ass_ind = -1
			if @times_done.count > 0
				current_day_ass_ind = 0
				current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
			end
			 	
			while current_week < Date.today
				puts current_week
				#if current_week.cweek % 4 == 0
				#	@last_months.append(@month)
				#	@month = []
				#end
				
				while @times_done.count > 0 and current_date_ass < current_week and current_day_ass_ind < @times_done.count-1
					current_day_ass_ind += 1
					current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
				end

				if @times_done.count > 0 and current_date_ass >= current_week and current_date_ass < current_week+@ts
					@last_months.append([@times_done[current_day_ass_ind].ding_zwei.ding_typ.name, current_week.to_s])
				else
					@last_months.append(["",current_week.to_s])
				end

				current_week += @ts
			end
			#if @month.count > 0
			#	@last_months.append(@month)
			#end
			@last_months = [[@last_months]]
		#end


		return {
			is_overdue: @is_overdue, 
			overdue: @overdue, 
			ts: @ts, 
			latest_time: @latest_time, 
			streak: @streak,
			last_month: @last_months}
	end
end
