class Robot
  @@instance = nil
  
  attr_accessor :delegate
  attr_accessor :response
  attr_accessor :message_queue
  
  def self.instance
    if @@instance.nil?
      @@instance = Robot.new
    end
    @@instance
  end
  
  def initialize
    @delegate = nil
    @response = nil
    @message_queue = []
    
    add_message_queue_observer
  end
  
  def add_message_queue_observer
    if @kvo_controller.nil?
      @kvo_controller = FBKVOController.controllerWithObserver self
    end
    
    @kvo_controller.observe self, keyPath:"message_queue", 
      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew, 
      block:(lambda do |observer, object, change|
        if message_queue.count > 0
          if @message_timer.nil?
            @message_timer = NSTimer.scheduledTimerWithTimeInterval 0.5, target:self, 
              selector:"pop_message_queue", userInfo:nil, repeats:true
          end
        else
          if @message_timer
            @message_timer.invalidate
            @message_timer = nil
          end
        end
      end)
  end
  
  def listen(request)
    loading
    
    send_request_to_server(request)
  end
  
  def send_request_to_server(request)
    # general message
    # { :message => message, :mode => 'message' }
    # answer
    # { :message => message, :mode => 'answer', :question => question }
    # click on tag
    # { :message => tag_clicked, :mode => 'click' }
    current_time         = Time.now
    request[:user_id]    = User.current.user_id
    request[:local_time] = { :raw => current_time, :hour => current_time.hour, :min => current_time.min }
    
    PFCloud.callFunctionInBackground "listen",
      withParameters: request,
      block:(lambda do |response, error|
        if !error
        else
          response = { :message => "Oops, something is wrong. Please try again!" }
        end
        handle_response(response)
      end)
    
    # example:
    # if request[:mode] == 'message'
    #   response = { :message => "ok #{request[:message]}", :streaming_songs => [], :function_name_to_execute => nil }
    # end
  end
  
  def loading
    if @delegate && @delegate.respond_to?('waiting_for_response')
      @delegate.waiting_for_response
    end
  end
  
  def handle_response(response)
    @response = response
    if @delegate && @delegate.respond_to?('handle_response')
      @delegate.handle_response(response)
    end
  end
  
  def clear_message_queue
    @message_queue = []
  end
  
  def queue_message_text(message_text)
    message_object = {
      :type => 'text',
      :text => message_text,
      :time_text => DateFormatter.toHumanReadableTime(Time.now),
      :direction => 'left'
    }
    queue_message_object(message_object)
  end
  
  def queue_message_object(message_object)
    if message_object
      self.message_queue = message_queue + [message_object]
    end
  end
  
  def pop_message_queue
    #NSLog 'pop_message_queue'
    message_object = self.message_queue.shift
    if message_object
      self.message_queue = self.message_queue
      say message_object
    end
  end
  
  def say(message_object)    
    if @delegate && @delegate.respond_to?('show_robot_message')
      @delegate.show_robot_message(message_object)
    end
  end
  
  def say_hello
    request = { :message => 'hello', :mode => 'greeting' }
    listen(request)
  end
  
  def send_like_event_with_song(song)
    request = { :message => nil, :mode => 'like', :song => song }
    send_request_to_server(request)
  end
  
  def send_unlike_event_with_song(song)
    request = { :message => nil, :mode => 'unlike', :song => song }
    send_request_to_server(request)
  end
  
  def send_swipe_event_with_song(song)
    request = { :message => nil, :mode => 'swipe', :song => song }
    send_request_to_server(request)
  end
  
end