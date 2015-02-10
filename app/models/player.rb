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
    @slider   = nil
    @is_ended_by_user = false
  end
  
  def is_ended_by_user?
    @is_ended_by_user
  end
  
  def ended_by_user
    @is_ended_by_user = true
  end
  
  def reset_is_ended_by_user
    @is_ended_by_user = false
  end
  
  def end_and_clear_by_user
    ended_by_user
    clear
  end
  
  def clear
    clear_movie_player_view
  end
  
  def toggle_playing_status_on_object(object)
    if @current_playing_object == object
      if object.is_from_youtube?
        toggle_video_playing_status
      else
        toggle_audio_playing_status
      end
    else
      play_object_by_user object
    end
  end
  
  def toggle_audio_playing_status
    
  end
  
  def loading
    if @delegate && @delegate.respond_to?('loading')
      @delegate.loading
    end
  end
  
  def finish_loading
    if @delegate && @delegate.respond_to?('finish_loading')
      @delegate.finish_loading
    end
  end
  
  def ended_by_itself
    if @delegate && @delegate.respond_to?('swipe_away_automatically')
      @delegate.swipe_away_automatically
    end
  end
  
  def play_object_by_user(object)
    ended_by_user
    play_object object
  end
  
  def play_object(object)
    @current_playing_object = object
    
    loading
    
    if object.is_from_youtube?
      @media_mode = 'video'
      play_youtube_object object
    else
      
    end
  end
  
  def set_slider(slider)
    @slider = slider
  end
  
  def start_slider_with_max_value(max_value)
    return if @slider.nil?
    
    @slider.addTarget self, action:"slider_value_changed:", forControlEvents:UIControlEventValueChanged
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchUpInside
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchUpOutside
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchCancel
    @slider.addTarget self, action:"slider_is_pressed:", forControlEvents:UIControlEventTouchDown
    
    @slider.maximumValue = max_value
    
    start_slider_timer
  end
  
  def slider_value_changed(sender)
  end
  
  def slider_is_pressed(sender)
    stop_slider_timer
  end
  
  def slider_is_released(sender)
    if @movie_player_controller
      @movie_player_controller.currentPlaybackTime = @slider.value
    end
    start_slider_timer
  end
  
  def start_slider_timer
    stop_slider_timer
    @slider_timer = NSTimer.scheduledTimerWithTimeInterval 1.0, target:self, selector:"update_slider:", userInfo:nil, repeats:true
    
    if @media_mode == 'video'
      if @movie_player_controller
        @movie_player_controller.play
      end
    else
      @audioPlayer.play
    end
  end
  
  def stop_slider_timer
    if @slider_timer
      @slider_timer.invalidate
      @slider_timer = nil
    end
    
    if @media_mode == 'video'
      if @movie_player_controller
        @movie_player_controller.pause
      end
    else
      @audioPlayer.pause
    end
  end
  
  def update_slider(sender)
    if @slider.nil?
      return
    end
    
    if @media_mode == 'video'
      if @movie_player_controller
        @slider.value = @movie_player_controller.currentPlaybackTime
      end
    else
      @slider.value = @audioPlayer.currentTrackPosition
    end
    
    update_time_labels
  end
  
  def update_time_labels
    if @delegate && @delegate.respond_to?('update_time_labels')
      remain_secs    = @slider.maximumValue - @slider.value
      remain_sec_str = format_time_from_seconds((remain_secs).to_int)
      played_sec_str = format_time_from_seconds((@slider.value).to_int)
      @delegate.update_time_labels(played_sec_str, remain_sec_str)
    end
  end
  
  def format_time_from_seconds(num_of_seconds)
    seconds = num_of_seconds % 60
    minutes = (num_of_seconds / 60)
    formatted_seconds = format('%02d', seconds)
    formatted_minutes = format('%02d', minutes)

    return "#{formatted_minutes}:#{formatted_seconds}"
  end
  
end