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
      @mediaMode = 'video'
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
    @slider.addTarget self, action:"sliderIsReleased:", forControlEvents:UIControlEventTouchUpInside
    @slider.addTarget self, action:"sliderIsReleased:", forControlEvents:UIControlEventTouchUpOutside
    @slider.addTarget self, action:"sliderIsReleased:", forControlEvents:UIControlEventTouchCancel
    @slider.addTarget self, action:"sliderIsPressed:", forControlEvents:UIControlEventTouchDown
    
    @slider.maximumValue = max_value
    
    start_slider_timer
  end
  
  def slider_value_changed(sender)
    #if @mediaMode == 'audio'
    #  @audioPlayer.seekToTrackPosition @slider.value
    #else
    #  # move this part to "sliderIsReleased"
    #  #if @moviePlayerController
    #  #  @moviePlayerController.currentPlaybackTime = @slider.value
    #  #end
    #end
  end
  
  def sliderIsPressed(sender)
    stopSliderTimer
  end
  
  def sliderIsReleased(sender)
    if @movie_player_controller
      @movie_player_controller.currentPlaybackTime = @slider.value
    end
    start_slider_timer
  end
  
  def start_slider_timer
    stopSliderTimer
    @sliderTime = NSTimer.scheduledTimerWithTimeInterval 1.0, target:self, selector:"updateSlider:", userInfo:nil, repeats:true
    
    @isPlayed = true
    if @mediaMode == 'video'
      if @movie_player_controller
        @movie_player_controller.play
      end
    else
      @audioPlayer.play
    end
  end
  
  def stopSliderTimer
    if @sliderTime
      @sliderTime.invalidate
      @sliderTime = nil
    end
    
    if @mediaMode == 'video'
      if @movie_player_controller
        @movie_player_controller.pause
      end
    else
      @audioPlayer.pause
    end
  end
  
  def updateSlider(sender)
    if @slider.nil?
      return
    end
    
    if @mediaMode == 'video'
      if @movie_player_controller
        @slider.value = @movie_player_controller.currentPlaybackTime
        
        #maxVal = Utility.formatTimeFromSeconds((@slider.maximumValue).to_int)
        #val    = Utility.formatTimeFromSeconds((@slider.value).to_int)
        #@timeLabel.text = "#{val} / #{maxVal}"
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