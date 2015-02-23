module RobotDelegate
  
  def handle_response(response)
    message_object = {
      :type => 'text',
      :text => response[:message],
      :time_text => DateFormatter.toHumanReadableTime(Time.now),
      :direction => 'left'
    }
    
    if response[:suggested_tags]
      message_object[:tags] = response[:suggested_tags]
    end
    
    if response[:stream_url]
      User.current.stream.connect response[:stream_url]
    end
    
    if response[:are_songs_updated]
      User.current.stream.update_songs_and_views
    end
    
    if response[:function_name_to_execute]
      self.performSelector response[:function_name_to_execute], withObject:nil, afterDelay:2.0
    end
    
    Robot.instance.queue_message_object(message_object)
  end
  
  def waiting_for_response
    @messages_view_controller.show_responding_status
  end
  
  def show_robot_message(message_object)
    @messages_view_controller.hide_responding_status
    
    show_message_ui
    @messages_view_controller.show_message_object(message_object)
  end
  
  def connect_to_facebook
    User.current.connect_to_facebook
  end
  
end