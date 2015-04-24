module YouTubePlayer
  attr_accessor :tried_num
  
  def initialize
    @movie_player_controller = nil
    @tried_num ||= 0
  end
  
  def is_video_playing?
    if @movie_player_controller
      @movie_player_controller.playerState == KYTPlayerStatePlaying
    else
      false
    end
  end
  
  def play_video
    if @movie_player_controller
      @movie_player_controller.playVideo
    end
  end
  
  def pause_video
    if @movie_player_controller
      @movie_player_controller.pauseVideo
    end
  end
  
  def play_video_from_the_beginning
    if @movie_player_controller
      @movie_player_controller.seekToSeconds 0.0, allowSeekAhead:true
    end
  end
  
  def play_youtube_object(object)
    @tried_num = 0
    if youtube_id = object.youtube_id
      handle_video_id youtube_id
    else
      query = "#{object.title} #{object.subtitle}"
      search query, startIndex:1, withBlock:(lambda do |results|
        if results.length > 0
          video = find_possible_youtube_video_from_results results
          if video
            youtube_id = video['youtube_id']
            handle_video_id youtube_id
          else
            handle_no_video_error
          end
        else
          handle_no_video_error
        end
      end)
    end
  end
  
  def find_possible_youtube_video_from_results(results)
    target_result = nil
    
    results.each do |result|
      youtube_id = result['youtube_id']
      duration   = result['duration'].to_i
      if youtube_id && duration < 60*10 # 10 mins
        target_result = result
        break
      end
    end
    
    target_result
  end
  
  def toggle_video_playing_status
    if @movie_player_controller 
      if @movie_player_controller.playerState == KYTPlayerStatePaused
        play_video
      else
        pause_video
      end
    end
  end
  
  def handle_no_video_error
    NSLog "handle_no_video_error"
    delegate.handle_no_video_error if delegate && delegate.respond_to?('handle_no_video_error')
  end
  
  def handle_video_id(video_id)
    NSLog "handle_video_id: %@", video_id
    if @movie_player_controller.nil?
      @movie_player_controller = YTPlayerView.alloc.init
    end
    
    player_vars = { "playsinline" => 1 }
    @movie_player_controller.loadWithVideoId video_id, playerVars:player_vars
    delegate.add_player_view(@movie_player_controller) if delegate && delegate.respond_to?('add_player_view')
  end
  
  def observe_movie_player(movie_player)
    NSNotificationCenter.defaultCenter.addObserver self,
        selector:"movie_player_playback_finished:",
        name:MPMoviePlayerPlaybackDidFinishNotification, object:movie_player
        
    NSNotificationCenter.defaultCenter.addObserver self,
        selector:"movie_player_playback_state_changed:",
        name:MPMoviePlayerPlaybackStateDidChangeNotification, object:movie_player
        
    NSNotificationCenter.defaultCenter.addObserver self,
        selector:"movie_player_load_state_changed:",
        name:MPMoviePlayerLoadStateDidChangeNotification, object:movie_player    
  end
  
  def unobserve_movie_player(movie_player)
    center = NSNotificationCenter.defaultCenter
    center.removeObserver self, name:MPMoviePlayerPlaybackDidFinishNotification, object:movie_player
    center.removeObserver self, name:MPMoviePlayerPlaybackStateDidChangeNotification, object:movie_player
    center.removeObserver self, name:MPMoviePlayerLoadStateDidChangeNotification, object:movie_player
  end
  
  def movie_player_playback_finished(notification)
    movie_player = notification.object
    reason       = notification.userInfo.objectForKey MPMoviePlayerPlaybackDidFinishReasonUserInfoKey
    
    case reason.intValue
    when MPMovieFinishReasonPlaybackEnded
      #NSLog "MPMovieFinishReasonPlaybackEnded"
      if is_ended_by_user?
        NSLog "is_ended_by_user"
      else
        NSLog "not ended_by_user"
        ended_by_itself
      end
    when MPMovieFinishReasonPlaybackError
      NSLog "MPMovieFinishReasonPlaybackError"
    when MPMovieFinishReasonUserExited
      NSLog "MPMovieFinishReasonUserExited"
    end
    
    if error = notification.userInfo.valueForKey("error")
      NSLog "Error: #{error.localizedDescription}"
    end
  end
  
  def movie_player_playback_state_changed(notification)
    movie_player   = notification.object
    playback_state = movie_player.playbackState
    
    case playback_state
    when MPMoviePlaybackStatePaused
      update_playing_status
    when MPMoviePlaybackStatePlaying
      update_playing_status
    when MPMoviePlaybackStateSeekingForward
    when MPMoviePlaybackStateSeekingBackward
    end
  end
  
  def movie_player_load_state_changed(notification)
    movie_player = notification.object
    
    if [MPMovieLoadStatePlaythroughOK, MPMovieLoadStatePlayable].include? movie_player.loadState
      reset_is_ended_by_user
      start_slider_with_max_value movie_player.duration
      set_playing_info_with_duration movie_player.duration
      
      finish_loading
    end
  end
  
  def update_playing_status
    delegate.update_playing_status if delegate && delegate.respond_to?('update_playing_status')
  end
  
  def clear_movie_player_view
    if @movie_player_controller
      @movie_player_controller.pause
      @movie_player_controller.initialPlaybackTime = -1
      @movie_player_controller.stop
      @movie_player_controller.initialPlaybackTime = -1
      @movie_player_controller.view.removeFromSuperview
      unobserve_movie_player @movie_player_controller
      @movie_player_controller = nil
    end
  end
  
  def update_movie_screen
    if @movie_player_controller
      orientation = UIDevice.currentDevice.orientation
      if orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight
        enter_fullscreen
      elsif [UIDeviceOrientationPortrait, UIDeviceOrientationPortraitUpsideDown].include? orientation
        exit_fullscreen
      end
    end
  end
  
  def is_fullscreen
    if @movie_player_controller
      @movie_player_controller.isFullscreen
    else
      false
    end
  end
  
  def enter_fullscreen
    if @movie_player_controller
      @movie_player_controller.setFullscreen true, animated:true
      @movie_player_controller.controlStyle = MPMovieControlStyleFullscreen
    end
  end
  
  def exit_fullscreen
    if @movie_player_controller
      @movie_player_controller.setFullscreen false, animated:true
      @movie_player_controller.controlStyle = MPMovieControlStyleNone
    end
  end
  
  def search(query, startIndex:startIndex, withBlock:block)
    NSLog "search youtube"
    query = query.urlEncodeUsingEncoding NSUTF8StringEncoding
    
    manager   = AFHTTPRequestOperationManager.manager
    urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&type=video&key=AIzaSyBs2bhIyg6LDVjhfFuEb1U0Rtntkxe5tN4"
    manager.GET urlString, parameters:nil, success:(lambda { |operation, responseObject|
      results = []
      if responseObject
        entries = responseObject['items']
        entries.each do |entry|
          if result = convertEntryToResult(entry)
            results << result
          end
        end
      end
      
      if block
        block.call(results)
      end
    }).weak!, failure:(lambda { |operation, error|
      NSLog("Error: %@", error)
      }).weak!
  end
  
  def convertEntryToResult(entry)
    thumbnails = entry["snippet"]["thumbnails"]
    if thumbnails.nil? # means this video might be private or not available
      return nil
    end
    
    if thumbnails["high"]
      thumbnailUrl = thumbnails["high"]["url"]
    else
      thumbnailUrl = thumbnails["default"]["url"]
    end
    
    title        = entry["snippet"]["title"]
    description  = entry["snippet"]["description"]
    youTubeId    = entry["id"]["videoId"]
    
    result = {
      'title'         => title,
      'description'   => description,
      'thumbnails'    => thumbnails,
      'thumbnail_url' => thumbnailUrl,
      'image_url'     => thumbnailUrl,
      'youtube_id'    => youTubeId,
    }
  end
  
end