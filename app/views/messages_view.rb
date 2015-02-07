class MessagesView < UITableView
  attr_accessor :controller
  
  def initWithFrame(frame)
    super frame
    
    self.backgroundColor = UIColor.colorWithRed 255/255.0, green:255/255.0, blue:255/255.0, alpha:0.1
    self.separatorStyle  = UITableViewCellSeparatorStyleNone
    
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    self.addGestureRecognizer tap_recognizer
    
    self
  end
  
  def tap_background
    if @controller && @controller.respond_to?('hide_message_ui')
      @controller.hide_message_ui
    end
  end
  
end