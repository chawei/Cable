module VideoPlayer
  attr_accessor :tried_num
  
  def initialize
    @movie_player_controller = nil
    @tried_num ||= 0
  end
  
  def is_video_playing?
    if @movie_player_controller
      @movie_player_controller.playbackState == MPMoviePlaybackStatePlaying
    else
      false
    end
  end
  
  def play_video
    if @movie_player_controller
      @movie_player_controller.play
    end
  end
  
  def pause_video
    if @movie_player_controller
      @movie_player_controller.pause
    end
  end
  
  def play_video_from_the_beginning
    if @movie_player_controller
      @movie_player_controller.currentPlaybackTime = 0.0
    end
  end
  
  def play_youtube_object(object)
    @tried_num = 0
    if youtube_id = object.youtube_id
      extract_url_with_youtube_id youtube_id
    else
      query = "#{object.title} #{object.subtitle}"
      search query, startIndex:1, withBlock:(lambda do |results|
        if results.length > 0
          video = find_possible_youtube_video_from_results results
          if video
            youtube_id = video['youtube_id']
            extract_url_with_youtube_id youtube_id
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
        retry_url_extraction_using_another_method
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
    return if @current_playing_object.nil?
    
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
  
  def search_v2(query, startIndex:startIndex, withBlock:block)
    query = query.urlEncodeUsingEncoding NSUTF8StringEncoding
    
    manager   = AFHTTPRequestOperationManager.manager
    urlString = "https://gdata.youtube.com/feeds/api/videos?q=#{query}&start-index=#{startIndex}&max-results=10&v=2&alt=json"
    manager.GET urlString, parameters:nil, success:(lambda { |operation, responseObject|
      results = []
      if responseObject['feed'] && responseObject['feed']['entry']
        entries = responseObject['feed']['entry']
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
  
  def convertEntryToResult_v2(entry)
    if entry["media$group"]["media$description"].nil?
      return nil
    end
    
    title        = entry["title"]["$t"]
    description  = entry["media$group"]["media$description"]["$t"]
    thumbnails   = entry["media$group"]["media$thumbnail"]
    thumbnailUrl = thumbnails[0]["url"]
    if entry["media$group"]["yt$videoid"]
      youTubeId    = entry["media$group"]["yt$videoid"]["$t"]
    else
      url   = entry["media$group"]["media$player"][0]["url"]
      regex = /youtube.com.*(?:\/|v=)([^&$]+)/
      youTubeId = url.match(regex)[1]
    end
    duration     = entry["media$group"]["yt$duration"]["seconds"]
    if duration.to_i == 0 # if the video is unavailable
      return nil
    end
    
    viewCount    = 0
    if entry["yt$statistics"]
      viewCount  = entry["yt$statistics"]["viewCount"]
    end
    
    numLikes     = 0
    if entry["yt$rating"]
      numLikes   = entry["yt$rating"]["numLikes"]
    end
    
    result = {
      'title'         => title,
      'description'   => description,
      'thumbnails'    => thumbnails,
      'thumbnail_url' => thumbnailUrl,
      'image_url'     => thumbnailUrl,
      'youtube_id'    => youTubeId,
      'view_count'    => viewCount,
      'num_likes'     => numLikes,
      'duration'      => duration
    }
  end
  
end