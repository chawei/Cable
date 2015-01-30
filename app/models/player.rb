class Player
  include VideoPlayer
  
  @@instance = nil
  
  attr_accessor :delegate
  
  def self.instance
    if @@instance.nil?
      @@instance = Player.new
    end
    @@instance
  end
  
  def initialize
    super
    
    @current_playing_object = nil
    @delegate = nil
  end
  
  def toggle_playing_status_on_object(object)
    if @current_playing_object == object
      if object.is_from_youtube?
        toggle_video_playing_status
      else
        toggle_audio_playing_status
      end
    else
      play_object object
    end
  end
  
  def toggle_audio_playing_status
    
  end
  
  def play_object(object)
    @current_playing_object = object
    
    if @delegate && @delegate.respond_to?('loading')
      @delegate.loading
    end
    
    if object.is_from_youtube?
      play_youtube_object object
    else
      
    end
  end
  
end