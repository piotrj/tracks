class Calendar
  attr_accessor :month, :month_name, :year, :days
  def initialize(options={})
    @month  = (options[:month] || Date.today.month).to_i
    @month_name = Date::MONTHNAMES[@month]
    @year   = (options[:year]  || Date.today.year).to_i
    @day    = options[:day].to_i
    @days   = Array.new
    @todos_que  = options[:todos] || Array.new
    
    initiate_days
  end
  
  def first_calendar_day
    first_month_day - first_month_day.cwday + 1
  end
  
  def first_month_day
      RAILS_DEFAULT_LOGGER.debug "year: #{@year}, month: #{@month}"
      Date.new(@year, @month)
  end
  
  def last_month_day
    Date.new(@year, @month, -1)
  end
  
  def last_calendar_day
    last_month_day + 7 - last_month_day.cwday
  end
  
  def initiate_days
    @todos_que = @todos_que.sort do |x,y| 
      y.due <=> x.due
    end
    
    first_calendar_day.upto(last_calendar_day) do |date|
      day = Day.new(date, determine_day_type(date))
      while !@todos_que.last.nil? and @todos_que.last.due == day.date
        day.add_todo(@todos_que.pop)
      end
      @days << day
    end
  end
  
  def determine_day_type(date)
    if date.month == @month
      if date.day == @day
        "selected"
      else
        if date.day == Date.today.day and date.month == Date.today.month and date.month == Date.today.year
          "today"
        else
          "this_month"
        end
      end
    else
      "other_month"
    end
  end
  
  def day_names
    days = Date::DAYNAMES
    days = days[1..6] + days[0..0]
  end
  
  def previous_year
    options = { :year => @year-1, :month => @month }
  end
  
  def previous_month
    month = @month
    year = @year
    if (month -= 1) < 1
      month = 12
      year -= 1
    end
    options = { :year => year, :month => month }
  end
  
  def next_year
    options = { :year => @year+1, :month => @month }
  end
  
  def next_month
    month = @month
    year = @year
    if (month += 1) > 12
      month = 1
      year += 1
    end
    options = { :year => year, :month => month }
  end
end

class Day
  attr_reader :type, :date
  
  def initialize(date, type)
    @date = date
    @type = type
    @todos = Array.new
  end
  
  def add_todo(todo)
    @todos << todo
  end
  
  def to_html
    html = %(<td class="#{["day_cell ", @type].join}">)
    html << %(<span class="day_number">#{@date.day}</span>)
    html << %(</td>\n)
  end
end