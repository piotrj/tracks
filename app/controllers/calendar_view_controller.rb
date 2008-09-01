class CalendarViewController < ApplicationController
  def index
    @calendar = Calendar.new(:year => params[:year], :month => params[:month], :day => params[:day])
  end
end
