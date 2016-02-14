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
	    	.where('name LIKE ?', "%#{search}%").distinct
	  else
	    with_translations.joins(:assoziations => :user_assoziations, :eingehende_assoziations => :user_assoziations)
	    	.where("user_assoziations.user_id = ?", user.id).distinct
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

		@streak = 0

		begin
			if @starttp_ding and @ts
				latest_date_done = nil
				current_date = Time.parse(@starttp_ding.name)
				if current_date < Time.now-90.day
					current_date += ((Time.now-90.day-current_date)/@ts.to_f).ceil*@ts
				end
				
				current_day_ass_ind = -1
				if @times_done.count > 0
					current_day_ass_ind = 0
					current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
				end

				# needed for comparison whether we started a new day/week/month/ ...
				last_date = current_date
				 	
				while current_date < Time.now

					new_block = check_for_new_block(last_date, current_date)
					if new_block
						@last_months.append(@month)
						@month = []
					end
					last_date = current_date

					while @times_done.count > 0 and current_date_ass < current_date and current_day_ass_ind < @times_done.count-1
						current_day_ass_ind += 1
						current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
					end

					if @times_done.count > 0 and current_date_ass >= current_date and current_date_ass < current_date+@ts
						# go through all dates which are still smaller than the deadline
						# as soon as we find one Done / Skip, we count it as done
						total_typ_name = "Todo Fail"
						while current_day_ass_ind < @times_done.count and current_date_ass < current_date+@ts
							typ_name = @times_done[current_day_ass_ind].ding_zwei.ding_typ.name
							if typ_name == "Todo Done"
								total_typ_name = "Todo Done"
							elsif typ_name == "Todo Skip"
								if total_typ_name != "Todo Done"
									total_typ_name = "Todo Skip"
								end
							end
							
							latest_date_done = current_date+@ts
							
							current_day_ass_ind += 1
							if current_day_ass_ind < @times_done.count
								current_date_ass = Time.parse(@times_done[current_day_ass_ind].ding_zwei.name)
							end
						end
					else
						total_typ_name = ""
					end

					# is it the current one?
					if current_date+@ts > Time.now
						if total_typ_name == "Todo Done" or total_typ_name == "Todo Skip"
							total_typ_name = "Today Done"
							@streak += 1
						elsif total_typ_name == "Todo Fail"
							total_typ_name = "Today Fail"
							@streak = 0
						else
							total_typ_name = "Today"
						end
					else
						if total_typ_name == "Todo Fail" or total_typ_name == ""
							@streak = 0
						else
							@streak += 1
						end
					end

					@month.append([total_typ_name, get_range_string(current_date)])

					current_date += @ts
				end
				
				@latest_time = latest_date_done
			end
		rescue => error
			@month = []
			puts $!.message
			puts error.backtrace
		end
		if @month.count > 0
			@last_months.append(@month)
			@month = []
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

	def get_range_string(current_date)
		return current_date.strftime('%Y/%m/%d') + " - " + (current_date + @ts).strftime('%Y/%m/%d')
	end

	def check_for_new_block(last_date, current_date)
		# insert new line to make it look nicer
		new_block = false
		if @ts < 1.day
			# new day?
			if last_date.day != current_date.day
				new_block = true
			end
		elsif @ts < 1.week
			# new week?
			if last_date.strftime('%W').to_i != current_date.strftime('%W').to_i
				new_block = true
			end
		elsif @ts < 1.month
			# new month?
			if last_date.strftime('%W').to_i/4 != current_date.strftime('%W').to_i/4
				new_block = true
			end
		elsif @ts < 1.year
			# new year?
			if last_date.year != current_date.year
				new_block = true
			end
		end
		return new_block
	end
end
