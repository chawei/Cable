class MessagesView < UIScrollView
  attr_accessor :controller
  
  def initWithFrame(frame)
    super frame
    
    @original_frame  = frame
    @original_height = self.size.height
    
    self.contentSize = [self.size.width, CBMessageBoxHeight+CBDefaultMargin*2]
    #self.registerClass MessageView, forCellWithReuseIdentifier:CBCategoryCellReuseIdentifier
    #self.alwaysBounceVertical = true
    
    self.backgroundColor = UIColor.colorWithRed 255/255.0, green:255/255.0, blue:255/255.0, alpha:0.1
    #self.separatorStyle  = UITableViewCellSeparatorStyleNone
    
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    self.addGestureRecognizer tap_recognizer
    
    self
  end
  
  def update_frame_with_keyboard_height(keyboard_height)
    if keyboard_height == 0
      self.frame = @original_frame
    else
      self.frame = [self.origin, [self.size.width, @original_height-keyboard_height]]
    end
  end
  
  def tap_background
    if @controller && @controller.respond_to?('hide_message_ui')
      @controller.hide_message_ui
    end
  end
  
  def test_add_message(direction='left')
    message_object = {
      :type => 'text',
      :text => "Got a pretty exciting event that you might be interested!",
      :time_text => "12:49 PM",
      :direction => direction
    }
    add_message_view_with_message_object(message_object)
  end
  
  def add_message_view_with_message_object(message_object)
    message_view = MessageView.alloc.initWithFrame [[0, 0], [self.size.width-CBDefaultMargin*2, 50]]
    message_view.message_object = message_object
    message_view.origin = [CBDefaultMargin, self.size.height-CBMessageBoxHeight-CBDefaultMargin*2-message_view.size.height]
    
    update_message_views_with_new_message_view(message_view)
    
    self.contentSize = [self.size.width, self.contentSize.height + message_view.size.height + CBDefaultMargin]
  end
  
  def update_message_views_with_new_message_view(new_message_view)
    subviews.each do |message_view|
      message_view.origin = [message_view.origin.x, 
        message_view.origin.y-new_message_view.size.height-CBDefaultMargin]
    end
    self.addSubview new_message_view
    #UIView.animateWithDuration(0.2,
    #                    delay:0.0,
    #                  options: UIViewAnimationCurveEaseInOut,
    #               animations:(lambda do
    #                   subviews.each do |message_view|
    #                     message_view.origin = [message_view.origin.x, 
    #                       message_view.origin.y-new_message_view.size.height-CBDefaultMargin]
    #                   end
    #                 end),
    #               completion:(lambda do |finished|
    #                   self.addSubview new_message_view
    #                 end))
  end
  
end