class Player
  include VideoPlayer
  
  @@instance = nil
  
  attr_accessor :delegate
  
  def self.instance
    if @@instance.nil?
      @@instance = Player.new
      
      audio_session = AVAudioSession.sharedInstance
      audio_session.setCategory AVAudioSessionCategoryPlayback, error:nil
      audio_session.setActive true, error:nil
    end
    @@instance
  end
  
  def initialize
    super
    
    @current_playing_object = nil
    @delegate = nil
    @slider   = nil
    @is_ended_by_user = false
    @should_continue_playing_in_background = false
    @bg_task_id = UIBackgroundTaskInvalid
  end
  
  def current_song_duration
    if @movie_player_controller
      @movie_player_controller.duration.to_f
    end
  end
  
  def is_playing?
    is_video_playing? # && is_audio_playing?
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
    @current_playing_object = nil
    clear_movie_player_view
  end
  
  def play_in_background
    @should_continue_playing_in_background = false
    gcdq = Dispatch::Queue.current
    delay_in_seconds = 0.01
    gcdq.after(delay_in_seconds) {
      play
    }
  end
  
  def pause_in_background
    gcdq = Dispatch::Queue.current
    delay_in_seconds = 0.01
    gcdq.after(delay_in_seconds) {
      pause
    }
  end
  
  def play
    play_video
  end
  
  def pause
    pause_video
  end
  
  def play_from_the_beginning
    play_video_from_the_beginning
  end
  
  def toggle_playing_status
    return if @current_playing_object.nil?
    
    if @current_playing_object.is_from_youtube?
      toggle_video_playing_status
    else
      toggle_audio_playing_status
    end
  end
  
  def toggle_playing_status_on_object(object)
    if @current_playing_object && @current_playing_object.id == object.id
      toggle_playing_status
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
  
  def update_playing_status
    if @delegate && @delegate.respond_to?('update_playing_status')
      @delegate.update_playing_status
    end
  end
  
  def set_slider(slider)
    @slider = slider
  end
  
  def start_slider_with_max_value(max_value)
    return if @slider.nil?
    
    @slider.userInteractionEnabled = true
    @slider.addTarget self, action:"slider_value_changed:", forControlEvents:UIControlEventValueChanged
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchUpInside
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchUpOutside
    @slider.addTarget self, action:"slider_is_released:", forControlEvents:UIControlEventTouchCancel
    @slider.addTarget self, action:"slider_is_pressed:", forControlEvents:UIControlEventTouchDown
    
    @slider.maximumValue = max_value
    
    start_slider_timer
  end
  
  def slider_value_changed(sender)
    update_time_labels
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
    
    if is_playing?
      if @delegate && @delegate.respond_to?('increment_played_sec')
        @delegate.increment_played_sec
      end
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
  
  def should_continue_playing_in_background?
    @should_continue_playing_in_background
  end
  
  def create_new_background_task
    @should_continue_playing_in_background = true
    
    new_task_id = UIBackgroundTaskInvalid
    new_task_id = UIApplication.sharedApplication.beginBackgroundTaskWithExpirationHandler nil
                
    if new_task_id != UIBackgroundTaskInvalid
    end

    if @bg_task_id != UIBackgroundTaskInvalid
      UIApplication.sharedApplication.endBackgroundTask(@bg_task_id)
      @bg_task_id = UIBackgroundTaskInvalid
    end

    @bg_task_id = new_task_id
  end
  
  def end_background_task
    if @bg_task_id != UIBackgroundTaskInvalid
      UIApplication.sharedApplication.endBackgroundTask(@bg_task_id)
      @bg_task_id = UIBackgroundTaskInvalid
    end
  end
  
  def set_playing_info_with_duration(duration)
    if @current_playing_object
      set_playing_info(@current_playing_object, duration:duration)
    end
  end
  
  def set_playing_info(song_object, duration:duration)
    playing_info_center = NSClassFromString "MPNowPlayingInfoCenter" 
    if playing_info_center      
      song_info = NSMutableDictionary.alloc.init
      song_info.setObject song_object.title, forKey:MPMediaItemPropertyTitle
      song_info.setObject song_object.subtitle, forKey:MPMediaItemPropertyArtist
      song_info.setObject "Cable Music", forKey:MPMediaItemPropertyAlbumTitle
      song_info.setObject duration, forKey:MPMediaItemPropertyPlaybackDuration
      
      if song_object.image_url
        image_url = NSURL.URLWithString song_object.image_url
        if image_url
          SDWebImageDownloader.sharedDownloader.downloadImageWithURL image_url,
                                                         options:0,
                                                        progress:(lambda do |receivedSize, expectedSize|
                                                        end),
                                                       completed:(lambda do |image, data, error, finished|
                                                         unless image && finished
                                                           image = CBPlayingNowIconImage
                                                         end
                                                         album_art = MPMediaItemArtwork.alloc.initWithImage image
                                                         song_info.setObject album_art, forKey:MPMediaItemPropertyArtwork
                                                         MPNowPlayingInfoCenter.defaultCenter.setNowPlayingInfo song_info
                                                       end)
        end
      end
      
      MPNowPlayingInfoCenter.defaultCenter.setNowPlayingInfo song_info
    end
  end
  
end