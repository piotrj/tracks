class Calendar
  attr_accessor :month, :month_name, :year, :days
  def initialize(options={})
    @month  = (options[:month] || Date.today.month).to_i
    @month_name = Date::MONTHNAMES[@month]
    @year   = (options[:year]  || Date.today.year).to_i
    @day    = options[:day].to_i
    @days   = Array.new
    @todos_que = Array.new
    # @todos_que  = options[:todos] || Array.new
    
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
    @todos_que = Todo.find(:all, :conditions => ["due > ? and due < ?", first_calendar_day, last_calendar_day], :order => "due")
    
    first_calendar_day.upto(last_calendar_day) do |date|
      day = Day.new(date, determine_day_type(date))
      while !@todos_que.last.nil? and @todos_que.first.due == day.date
        day.add_todo(@todos_que.shift)
      end
      @days << day
    end
  end
  
  def determine_day_type(date)
    if date == Date.today
      "today"
    else
      if date.month == @month and date.year == @year
        if date.day == @day
          "selected"
        else
          "this_month"
        end
      else
        "other_month"
      end
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
  include ActionView::Helpers::TextHelper
  attr_reader :type, :date, :todos
  
  def initialize(date, type)
    @date = date
    @type = type
    @todos = Array.new
  end
  
  def add_todo(todo)
    @todos << todo
  end
end