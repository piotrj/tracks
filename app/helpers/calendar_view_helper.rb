module CalendarViewHelper
  
  def count_pluralize(count, text)
    case count
      when 1: text
      else text.pluralize()
    end
  end
  
end
