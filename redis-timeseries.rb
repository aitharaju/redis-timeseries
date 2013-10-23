class RedisTimeSeries
	@redis = {}

	def initialize redis
		server = redis[:sever]
		port = redis[:port]
        	@redis = Redis.new(:host => server , :port => port)
	end

	# key 
	# timestamp in seconds
	def add key, timestamp
		created = timestamp
		time = Time.at(created).to_datetime
		year_key = key + ":year:" + find_year(time).to_s
		month_key = key + ":month" + find_month(time).to_s
		week_key = key + ":week:" + find_week(time).to_s
		day_key = key + ":day:" + find_day(time).to_s
		hour_key = key + ":hour:" + find_hour(time).to_s
		keys = [year_key,month_key,week_key,day_key,hour_key]
		keys.each do |k|
			@redis.incr key
		end
	end

	# start_date = timestamp of the start date
	# end_date = timestamp of the end date
	# filter_by = day, week, month, year
	def get key, start_date, end_date, filter_by
		start_time = Time.at(start_date.to_i).to_datetime
		end_time = Time.at(end_date.to_i).to_datetime
		graph = []
		filter_by=@filter_by
		
		# work in progress
		if filter_by == 'year' || filter_by == 'month'
			return ''
		end
	
		if filter_by == 'week'
			start_day = find_week start_time
			end_day = find_week end_time
			incr = 24*60*60*7
		end	

		if filter_by == 'day'
			start_day = find_day start_time
			end_day = find_day end_time
			incr = 24*60*60
		end
		if filter_by == 'hour'
			start_day = find_day start_time
			end_day = find_day end_time
			incr = 60*60
		end

		date = start_day
		while date <= end_day do
			temp = {}
			temp[:date] = date
			temp[:value] = @redis.get key+":#{filter_by}:"+date.to_s
			graph << temp
			date = date + incr			
		end
		graph
	end

	# Delete all the data for a given key pattern
	def delete key
	end

	# finds the timestamp at the start of the given year
	def find_year time
		year = time.year
		year_timestamp = Date.new(year).to_time.to_i
		year_timestamp
	end

	# finds the timestamp at the start of the given month
	def find_month time
		year = time.year
		month = time.month
		month_timestamp = Date.new(year,month,1).to_time.to_i
		month_timestamp
	end

	# finds the timestamp at the start of the given week
	def find_week time
		year = time.year
		week = time.cweek
		week_timestamp = Date.commercial(year,week,1).to_time.to_i	
		week_timestamp
	end

	# finds the timestamp at the start of the given day
	def find_day time
		year = time.year
		month = time.month
		day = time.yday
		day_timestamp = Date.ordinal(year,day).to_time.to_i	
		day_timestamp

	end

	# finds the timestamp at the start of the day
	def find_hour time
		hour_timestamp = time.change(:min => 0).to_time.to_i
		hour_timestamp
	end

end
