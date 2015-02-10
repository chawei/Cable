class DateFormatter
  @@formattedTime = NSCache.new
  
  def self.clearFormattedTimeCache
    @@formattedTime = NSCache.new
  end
  
  def self.toTime(time)
    if @todayFormatter.nil?
      @todayFormatter = NSDateFormatter.alloc.init
      @todayFormatter.dateStyle = NSDateFormatterNoStyle
      @todayFormatter.timeStyle = NSDateFormatterShortStyle
      #@todayFormatter.setDateFormat NSDateFormatter.dateFormatFromTemplate "hh:mm a", options:0, locale:NSLocale.currentLocale
    end
    
    return @todayFormatter.stringFromDate(time).downcase
  end
  
  def self.toDate(time)
    if @dateFormatter.nil?
      @dateFormatter = NSDateFormatter.alloc.init
      @dateFormatter.doesRelativeDateFormatting = true
      @dateFormatter.dateStyle = NSDateFormatterShortStyle
      @dateFormatter.timeStyle = NSDateFormatterNoStyle
      #@dateFormatter.setDateFormat NSDateFormatter.dateFormatFromTemplate "MM/dd", options:0, locale:NSLocale.currentLocale
    end
    
    return @dateFormatter.stringFromDate time
  end
  
  def self.toHumanReadableTime(time)
    if time.nil?
      return 'sending'
    end

    if @@formattedTime["#{time}"].nil?
      formattedTime = toDate time
      if formattedTime == NSLocalizedString("Today", nil)
        formattedTime = toTime(time)
      end
      @@formattedTime["#{time}"] = formattedTime
    end
    return @@formattedTime["#{time}"]
  end
  
end