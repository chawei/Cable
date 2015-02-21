module RobotDelegate
  
  def handle_response(response)
    message_object = {
      :type => 'text',
      :text => response[:message],
      :time_text => DateFormatter.toHumanReadableTime(Time.now),
      :direction => 'left'
    }
    Robot.instance.queue_message_object(message_object)
    
    if response[:stream_url]
      User.current.stream.connect response[:stream_url]
    end
    
    if response[:are_songs_updated]
      User.current.stream.update_songs_and_views
    end
    
    if response[:function_name_to_execute]
      self.performSelector response[:function_name_to_execute], withObject:nil, afterDelay:2.0
    end
  end
  
  def show_robot_message(message_object)
    show_message_ui
    @messages_view_controller.show_message_object(message_object)
  end
  
  def connect_to_facebook
    User.current.connect_to_facebook
  end
  
end