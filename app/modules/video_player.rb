module VideoPlayer
  attr_accessor :tried_num
  
  def initialize
    @movie_player_controller = nil
    @tried_num ||= 0
  end
  
  def play_youtube_object(object)
    if youtube_id = object.youtube_id
      @tried_num = 0
      extract_url_with_youtube_id youtube_id
    end
  end
  
  def toggle_video_playing_status
    if @movie_player_controller 
      if @movie_player_controller.playbackState == MPMoviePlaybackStatePaused
        @movie_player_controller.play
      else
        @movie_player_controller.pause
      end
    end
  end
  
  def handle_no_video_error
    NSLog "handle_no_video_error"
    delegate.handle_no_video_error if delegate && delegate.respond_to?('handle_no_video_error')
  end
  
  def handle_video_url(video_url)
    NSLog "handle_video_url: %@", video_url
    url = NSURL.URLWithString video_url
    if @movie_player_controller.nil?
      @movie_player_controller = MPMoviePlayerController.alloc.initWithContentURL url
      @movie_player_controller.controlStyle = MPMovieControlStyleNone
      @movie_player_controller.prepareToPlay
      observe_movie_player @movie_player_controller
    else      
      @movie_player_controller.contentURL = url
      @movie_player_controller.prepareToPlay
    end
    
    @movie_player_controller.play # IMPORTANT: we wanna play first, so if there's an error, the notif can capture it 
    delegate.add_player_view(@movie_player_controller.view) if delegate && delegate.respond_to?('add_player_view')
  end
  
  def extract_url_with_youtube_id_by_lb(youtube_id)
    url_str   = "http://www.youtube.com/watch?v=#{youtube_id}"
    url       = NSURL.URLWithString url_str
    extractor = LBYouTubeExtractor.alloc.initWithURL url, quality:LBYouTubeVideoQualityLarge
    extractor.extractVideoURLWithCompletionBlock(lambda do |video_url, error|
      if video_url
        verify_url video_url.absoluteString
        break
      else
        NSLog "video_url is nil"
        handle_no_video_error
      end
    end)
  end
  
  def extract_url_with_youtube_id(youtube_id)
    video_identifier = youtube_id
    XCDYouTubeClient.defaultClient.getVideoWithIdentifier video_identifier, completionHandler:(lambda do |video, error|
      if video && video.streamURLs.count > 0
        #if Cable.networkStatus == "wifi"
        #  qualities = [XCDYouTubeVideoQualityHD720, XCDYouTubeVideoQualityMedium360, XCDYouTubeVideoQualitySmall240]
        #else
        #  qualities = [XCDYouTubeVideoQualitySmall240, XCDYouTubeVideoQualityMedium360]
        #end
        qualities = [XCDYouTubeVideoQualityHD720, XCDYouTubeVideoQualityMedium360, XCDYouTubeVideoQualitySmall240]
        
        video_url = nil
        qualities.each do |quality|
          video_url = video.streamURLs[quality]
          if video_url
            verify_url video_url.absoluteString
            break
          end
        end
        
        if video_url.nil?
          NSLog "video_url is nil"
          handle_no_video_error
        end
      else
        NSLog "video is nil"
        handle_no_video_error
      end
    end)
  end
  
  def verify_url(url_str)
    url     = NSURL.URLWithString url_str
    request = NSMutableURLRequest.requestWithURL url
    request.setHTTPMethod "HEAD"

    connection = NSURLConnection.connectionWithRequest request, delegate:self
  end
  
  def connection(connection, didReceiveResponse:response)
    if response.statusCode == 200
      if response.URL
        handle_video_url(response.URL.absoluteString)
      else
        NSLog "No response.URL"
      end
    else
      retry_url_extraction_using_another_method
    end
  end
  
  def retry_url_extraction_using_another_method
    youtube_id = @current_playing_object.youtube_id
    if @tried_num < CBMaxNumOfTry
      NSLog "try again #{youtube_id}"
      extract_url_with_youtube_id_by_lb(youtube_id)
    else
      handle_no_video_error
    end
    @tried_num += 1
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
  
  def movie_player_playback_finished(notification)
    
  end
  
  def movie_player_playback_state_changed(notification)
    
  end
  
  def movie_player_load_state_changed(notification)
    movie_player = notification.object
    
    if [MPMovieLoadStatePlaythroughOK, MPMovieLoadStatePlayable].include? movie_player.loadState
      start_slider_with_max_value movie_player.duration
      finish_loading
    end
  end
  
  def clear_movie_player_view
    if @movie_player_controller
      @movie_player_controller.pause
      @movie_player_controller.initialPlaybackTime = -1
      @movie_player_controller.stop
      @movie_player_controller.initialPlaybackTime = -1
      @movie_player_controller.view.removeFromSuperview
    end
  end
  
end