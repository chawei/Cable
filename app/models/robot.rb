class Robot
  @@instance = nil
  
  attr_accessor :delegate
  attr_accessor :response
  
  def self.instance
    if @@instance.nil?
      @@instance = Robot.new
    end
    @@instance
  end
  
  def initialize
    @delegate = nil
    @response = nil
  end
  
  def listen(request)
    loading
    
    send_request_to_server(request)
  end
  
  def send_request_to_server(request)
    # success
    response = { :message => "hi there", :streaming_songs => [], :function_name_to_execute => nil }
    
    # error
    
    handle_response(response)
  end
  
  def loading
    if @delegate && @delegate.respond_to?('loading')
      @delegate.loading
    end
  end
  
  def handle_response(response)
    @response = response
    if @delegate && @delegate.respond_to?('handle_response')
      @delegate.handle_response(response)
    end
  end
  
end