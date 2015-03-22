class CardView < UIView
  include Style
  include CardViewDelegate
  include FocusedSliderView
  
  attr_accessor :liked_users_view
  
  def init_with_origin(origin)
    @song_object     = nil
    @is_first_tapped = false
    @is_removed      = false
    @played_sec      = 0
    
    initWithFrame [origin, [CardView.default_width, card_height]]
    @origin        = self.frame.origin
    @last_location = self.center
    
    setup_view
    
    self
  end
  
  def self.default_width
    card_left_margin = CBDefaultMargin
    card_view_width  = App.screen_width - card_left_margin*2
  end
  
  def self.default_height
    if App.is_small_screen?
      310
    else
      if App.screen_height > 660.0
        450
      else
        380
      end
    end
  end
  
  def card_height
    CardView.default_height
  end
  
  def card_width
    self.size.width
  end
  
  def card_padding
    CBDefaultMargin
  end
  
  def card_top_padding
    if App.is_small_screen?
      card_top_padding = 10
    else
      card_top_padding = 15
    end
  end
  
  def media_view_height
    if App.is_small_screen?
      self.size.height - card_top_padding - CBSourceButtonHeight/2 - CBDefaultMargin*2 - CBDefaultButtonHeight
    else
      card_width
    end
  end
  
  def gray_color
    UIColor.colorWithRed 200/255.0, green:200/255.0, blue:200/255.0, alpha:1.0
  end
  
  def setup_view
    self.backgroundColor = UIColor.whiteColor
    
    msb_right_margin = CBDefaultMargin
    msb_width        = 24
    
    @media_source_button       = UIButton.buttonWithType UIButtonTypeCustom
    @media_source_button.frame = [[card_width-msb_right_margin-msb_width, card_top_padding], [msb_width, msb_width]]
    @media_source_button.setImage CBYouTubeIconImage, forState:UIControlStateNormal
    @media_source_button.layer.zPosition = CBMediaSourceButtonZPosition
    @media_source_button.userInteractionEnabled = false
    self.addSubview @media_source_button
    
    mv_top_margin = card_top_padding + msb_width/2
    @media_view = UIView.alloc.initWithFrame([[0, mv_top_margin], [card_width, media_view_height]])
    @media_view.backgroundColor = UIColor.blackColor
    self.addSubview @media_view
    self.sendSubviewToBack @media_view
    
    #add_labels_after_view @media_view
    add_cover_art_view_on_view @media_view
    add_playing_status_button_on_view @media_view
    add_overlay_view_on_view @media_view
    add_media_info_view_on_view @media_view
    add_liked_users_view
    add_buttons
    
    add_pan_recognizer
    add_tap_recognizer
    
    apply_rounded_corner
  end
  
  def add_labels_after_view(view)    
    @title_label = UILabel.alloc.initWithFrame [[card_padding, view.frame.origin.y+view.size.height+CBDefaultMargin],
      [card_width-card_padding*2, CBCardTitleLabelMaxHeight]]
    @title_label.numberOfLines = 2
    @title_label.textColor = UIColor.blackColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:18.0)
    @title_label.text = "Unknown"
    self.addSubview @title_label
    
    @subtitle_label = UILabel.alloc.initWithFrame [[card_padding, @title_label.frame.origin.y+@title_label.size.height+CBDefaultMargin],
      [card_width-card_padding*2, CBCardTitleLabelMaxHeight]]
    @subtitle_label.numberOfLines = 0
    @subtitle_label.textColor = UIColor.grayColor
    @subtitle_label.setFont UIFont.fontWithName(CBLightFontName, size:12.0)
    @subtitle_label.text = "Unknown Artist / 0 min 0 sec"
    @subtitle_label.sizeToFit
    self.addSubview @subtitle_label
  end
  
  def add_cover_art_view_on_view(view)
    @cover_art_view = UIImageView.alloc.initWithFrame([[0, 0], [view.size.width, view.size.height]])
    @cover_art_view.contentMode     = UIViewContentModeScaleAspectFit
    @cover_art_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:1.0
    
    view.addSubview @cover_art_view
  end
  
  def add_playing_status_button_on_view(view)
    @playing_status_button = UIButton.buttonWithType UIButtonTypeCustom
    @playing_status_button.frame  = [[0, 0], [CBPlayingStatusIconWidth, CBPlayingStatusIconHeight]]
    if @cover_art_view
      @playing_status_button.center = @cover_art_view.center
    end
    @playing_status_button.setBackgroundImage CBPlayerPlayIconImage, forState:UIControlStateNormal
    @playing_status_button.addTarget self, action:"tap_and_toggle_play", forControlEvents:UIControlEventTouchUpInside
    @playing_status_button.layer.zPosition = CBPlayingStatusButtonZPosition
    view.addSubview @playing_status_button
  end
  
  def add_overlay_view_on_view(view)
    @overlay_view = UIView.alloc.initWithFrame([[0, 0], view.size])
    @overlay_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.2
    @overlay_view.layer.zPosition = CBOverlayViewZPosition
    
    view.addSubview @overlay_view
  end
  
  def add_media_info_view_on_view(view)
    @media_info_view = UIView.alloc.initWithFrame([[0, 0], view.size])
    @media_info_view.layer.zPosition = CBMediaInfoViewZPosition
    
    add_labels_on_view(@media_info_view)
    add_slider_on_view(@media_info_view)
    
    view.addSubview @media_info_view
  end
  
  def add_labels_on_view(target_view)
    @title_label = UILabel.alloc.initWithFrame [[card_padding, CBDefaultMargin],
      [card_width-card_padding*2, CBCardTitleLabelMaxHeight]]
    @title_label.numberOfLines = 2
    @title_label.textColor = UIColor.whiteColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:18.0)
    @title_label.text = "Unknown"
    target_view.addSubview @title_label
    
    @subtitle_label = UILabel.alloc.initWithFrame [[card_padding, @title_label.frame.origin.y+@title_label.size.height+CBDefaultMargin],
      [card_width-card_padding*2, CBCardTitleLabelMaxHeight]]
    @subtitle_label.numberOfLines = 0
    @subtitle_label.textColor = gray_color
    @subtitle_label.setFont UIFont.fontWithName(CBLightFontName, size:12.0)
    @subtitle_label.text = "Unknown Artist / 0 min 0 sec"
    @subtitle_label.sizeToFit
    target_view.addSubview @subtitle_label
  end
  
  def add_slider_on_view(target_view)
    origin_y = @subtitle_label.frame.origin.y+@subtitle_label.size.height+CBDefaultMargin
    @time_slider_view = UIView.alloc.initWithFrame [[CBDefaultMargin, origin_y], 
      [card_width-CBDefaultMargin*2, CBSliderHeight+5]]
    
    @played_time_label = UILabel.alloc.initWithFrame [[0, 0], 
      [CBTimeLabelWidth, @time_slider_view.size.height]]
    @played_time_label.numberOfLines = 1
    @played_time_label.textAlignment = NSTextAlignmentLeft
    @played_time_label.textColor     = gray_color
    @played_time_label.setFont UIFont.fontWithName(CBLightFontName, size:10.0)
    @played_time_label.text = "--:--"
    @time_slider_view.addSubview @played_time_label
    
    @remain_time_label = UILabel.alloc.initWithFrame [[@time_slider_view.size.width-CBTimeLabelWidth, 0], 
      [CBTimeLabelWidth, @time_slider_view.size.height]]
    @remain_time_label.numberOfLines = 1
    @remain_time_label.textAlignment = NSTextAlignmentRight
    @remain_time_label.textColor     = gray_color
    @remain_time_label.setFont UIFont.fontWithName(CBLightFontName, size:10.0)
    @remain_time_label.text = "--:--"
    @time_slider_view.addSubview @remain_time_label
    
    CBSlider.setup_appearance
    @slider = CBSlider.alloc.initWithFrame [[@played_time_label.size.width, 2], 
      [@time_slider_view.size.width-CBTimeLabelWidth*2, CBSliderHeight]]
      
    @slider.userInteractionEnabled = false
    @slider.addTarget self, action:"show_focused_slider", forControlEvents:UIControlEventTouchDown
    @slider.addTarget self, action:"hide_focused_slider", forControlEvents:UIControlEventTouchUpInside
    @slider.addTarget self, action:"hide_focused_slider", forControlEvents:UIControlEventTouchUpOutside
    @slider.addTarget self, action:"hide_focused_slider", forControlEvents:UIControlEventTouchCancel
    @time_slider_view.addSubview @slider
      
    target_view.addSubview @time_slider_view
  end
  
  def add_buttons
    action_button_width  = 32
    action_button_height = 32
    button_bottom_margin = CBDefaultMargin
    button_left_margin   = CBDefaultMargin
    
    @like_button       = UIButton.buttonWithType UIButtonTypeCustom
    @like_button.frame = [[card_width-card_padding-action_button_width, card_height-action_button_height-button_bottom_margin],
      [action_button_width, action_button_height]]
    @like_button.setImage CBLikeIconImage, forState:UIControlStateNormal
    @like_button.addTarget self, action:"toggle_like_button", forControlEvents:UIControlEventTouchUpInside
    self.addSubview @like_button
    
    @share_button       = UIButton.buttonWithType UIButtonTypeCustom
    @share_button.frame = [[card_width-card_padding-(action_button_width+5)*2, card_height-action_button_height-button_bottom_margin], 
      [action_button_width, action_button_height]]
    @share_button.setImage CBShareIconImage, forState:UIControlStateNormal
    @share_button.addTarget self, action:"press_share_button", forControlEvents:UIControlEventTouchUpInside
    self.addSubview @share_button
  end
  
  def add_pan_recognizer
    @pan_recognizer = UIPanGestureRecognizer.alloc.initWithTarget self, action:"detect_pan:"
    self.addGestureRecognizer @pan_recognizer
  end
  
  def remove_pan_recognizer
    if @pan_recognizer
      self.removeGestureRecognizer @pan_recognizer
    end
  end
  
  def add_tap_recognizer
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_and_toggle_play"
    self.addGestureRecognizer tap_recognizer
  end
  
  def add_liked_users_view
    @liked_users_view = LikedUsersView.alloc.init
    @liked_users_view.delegate = self
    @liked_users_view.frame = [[card_padding, self.size.height-32-CBDefaultMargin],
      [card_width-card_padding*2, 32+CBDefaultMargin]]
      
    if App.is_small_screen?
      self.addSubview @liked_users_view
      #self.sendSubviewToBack @liked_users_view
    else
      @media_info_view.addSubview @liked_users_view
      #@media_info_view.sendSubviewToBack @liked_users_view
    end
  end
  
  def update_liked_users_view
    if @liked_users_view
      @liked_users_view.subviews.makeObjectsPerformSelector "removeFromSuperview"
      if song_object  
        liked_users = song_object.liked_users
        liked_users.each_index do |index|
          user_pic_url = NSURL.URLWithString liked_users[index][:user_profile_url]
          
          SDWebImageDownloader.sharedDownloader.downloadImageWithURL user_pic_url,
            options:0,
            progress:(lambda do |receivedSize, expectedSize|
            end),
            completed:(lambda do |image, data, error, finished|
              if image && finished
                user_image       = image
                heart_icon_image = UIImage.imageNamed "assets/icon_friend_like"
    
                new_size = CGSizeMake(64, 64)
                UIGraphicsBeginImageContext(new_size)
                user_image.drawInRect CGRectMake(0,6,52,52)
                heart_icon_image.drawInRect CGRectMake(40,40,24,24), blendMode:KCGBlendModeNormal, alpha:1.0
                blended_image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
    
                user_button       = UIButton.buttonWithType UIButtonTypeCustom
                user_button.frame = [[(32+5)*index, 0], [32, 32]]
                user_button.setImage blended_image, forState:UIControlStateNormal
                user_button.addTarget self, action:"press_user_button", forControlEvents:UIControlEventTouchUpInside
      
                @liked_users_view.addSubview user_button
              end
            end)
        end
        
        update_liked_users_view_frame
      end
    end
  end
  
  def update_liked_users_view_frame
    if App.is_small_screen?
      update_liked_users_view_at_the_bottom
    else
      update_liked_users_view_after_view @time_slider_view
    end
    
    liked_users = song_object.liked_users
    if liked_users.length == 0
      @liked_users_view.frame = [@liked_users_view.origin, [0, 0]]
    end
  end
  
  def update_liked_users_view_at_the_bottom
    @liked_users_view.origin = [card_padding, self.size.height-32-CBDefaultMargin]
  end
  
  def update_liked_users_view_after_view(view)
    if view
      @liked_users_view.origin = [card_padding, view.frame.origin.y+view.size.height+CBDefaultMargin]
    end
  end
  
  def set_player
    Player.instance.delegate = self
    if @slider
      Player.instance.set_slider @slider
    end
  end
  
  def tap_and_toggle_play
    if @song_object
      # TODO: review this part
      set_player
      Player.instance.toggle_playing_status_on_object @song_object
    end
  end
  
  def play
    if @song_object
      set_player
      Player.instance.play_object @song_object
    end
  end
  
  def loading
    @loading_view = UIView.alloc.initWithFrame @cover_art_view.frame
    @loading_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.24
    activity_view = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleWhiteLarge
    activity_view.center = @loading_view.center
    activity_view.startAnimating
    @loading_view.addSubview activity_view
    
    @media_view.addSubview @loading_view
    
    @playing_status_button.alpha = 0.0
  end
  
  def finish_loading
    @loading_view.removeFromSuperview
  end
  
  def handle_no_video_error
    finish_loading
    
    @status_view = UIView.alloc.initWithFrame @cover_art_view.frame
    @status_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.50
    status_label = UILabel.alloc.initWithFrame [[0, 0], [card_width-CBDefaultMargin*2, 50]]
    status_label.center = @cover_art_view.center
    status_label.numberOfLines = 2
    status_label.textAlignment = NSTextAlignmentCenter
    status_label.textColor = UIColor.whiteColor
    status_label.setFont UIFont.fontWithName(CBLightFontName, size:16.0)
    status_label.text = "Oops, this video is not available due to copyright restrictions."
    @status_view.addSubview status_label
    
    @media_view.addSubview @status_view
  end
  
  def song_object=(song_object)
    @song_object = song_object
    update_view
  end
  
  def song_object
    @song_object
  end
  
  def update_view
    return if @song_object.nil?
    
    if @song_object.image_url
      @cover_art_view.setImageWithURL NSURL.URLWithString(@song_object.image_url),
                         placeholderImage:nil
    end
    
    if @song_object.title
      @title_label.text = @song_object.title
      @title_label.setVerticalAlignmentTopWithHeight(CBCardTitleLabelMaxHeight)
    end
    
    if @song_object.subtitle
      @subtitle_label.frame = [[card_padding, @title_label.frame.origin.y+@title_label.size.height+CBSmallMargin], 
        [card_width-card_padding*2, CBCardTitleLabelMaxHeight]]
      @subtitle_label.text = @song_object.subtitle
      @subtitle_label.setVerticalAlignmentTopWithHeight(CBCardTitleLabelMaxHeight)
    end
    
    @time_slider_view.frame = [[@time_slider_view.frame.origin.x, @subtitle_label.frame.origin.y+@subtitle_label.size.height+CBDefaultMargin],
      @time_slider_view.size]
    
    update_source_button
    update_liked_users_view
    update_media_info_view
    update_like_button
  end
  
  def update_source_button
    if @song_object.can_be_played_in_spotify?
      @media_source_button.setImage CBSpotifyIconImage, forState:UIControlStateNormal
    else
      @media_source_button.setImage CBYouTubeIconImage, forState:UIControlStateNormal
    end
  end
  
  def update_media_info_view
    if App.is_small_screen?
      new_size = [@media_info_view.size.width, 
        @time_slider_view.frame.origin.y+@time_slider_view.size.height+CBDefaultMargin]
    else
      new_size = [@media_info_view.size.width, 
        @liked_users_view.frame.origin.y+@liked_users_view.size.height]
    end
    
    new_origin_y = @media_view.size.height-new_size[1]
    @media_info_view.frame = [[0, new_origin_y], new_size]
  end
  
  def update_time_labels(played_sec_str, remain_sec_str)
    @played_time_label.text = played_sec_str
    @remain_time_label.text = remain_sec_str
  end
  
  def update_like_button
    if song_object
      if User.current.has_favorited_song?(song_object.hash)
        @like_button.setImage CBLikedIconImage, forState:UIControlStateNormal
      else
        @like_button.setImage CBLikeIconImage, forState:UIControlStateNormal
      end
    end
  end
  
  def toggle_like_button
    current_state_image = @like_button.imageForState UIControlStateNormal
    if current_state_image == CBLikeIconImage
      if song_object
        @like_button.setImage CBLikedIconImage, forState:UIControlStateNormal
        User.current.add_favorite_song song_object.hash
      end
    else
      if song_object
        @like_button.setImage CBLikeIconImage, forState:UIControlStateNormal
        User.current.remove_favorite_song song_object.hash
      end
    end
  end
  
  def update_playing_status
    if Player.instance.is_playing?
      @playing_status_button.setBackgroundImage CBPlayerPauseIconImage, forState:UIControlStateNormal
      UIView.animateWithDuration(0.5,
                            delay:1.0,
                          options: UIViewAnimationCurveEaseInOut,
                       animations:(lambda do
                           @playing_status_button.alpha = 0.0
                         end),
                       completion:(lambda do |finished|
                         end))
    else
      @playing_status_button.alpha = 1.0
      @playing_status_button.setBackgroundImage CBPlayerPlayIconImage, forState:UIControlStateNormal
    end
  end
  
  def press_share_button
    PopUpView.share_song song_object
  end
  
  def press_user_button
    NSLog "press_user_button"
  end
  
  def detect_pan(recognizer)    
    translation = recognizer.translationInView self.superview
    velocity    = recognizer.velocityInView self.superview
    
    if recognizer.state == UIGestureRecognizerStateChanged
      if @direction.nil?
        if (translation.x).abs > (translation.y).abs
          @direction = "horizontal"
          if velocity.x > 0
            #NSLog "pan right"
          else
            #NSLog "pan left"
          end
        else
          @direction = "vertical"
          if velocity.y > 0
            #NSLog "pan down"
          end
        end
      end
      
      if CBDirectionToDiscard == 'top'
        self.center = CGPointMake(@last_location.x, @last_location.y + translation.y)
      else
        rads = 0.1/180.0 * Math::PI * translation.x
        new_transform  = CGAffineTransformMakeRotation rads
        self.transform = new_transform
      
        self.alpha = 1 - (translation.x).abs/1000

        self.center = CGPointMake(@last_location.x + translation.x, @last_location.y + translation.y)
      end
    end
    
    if recognizer.state == UIGestureRecognizerStateEnded
      @direction = nil
      
      if CBDirectionToDiscard == 'top'
        if velocity.y < CBDiscardVelocityThreshold || (self.center.y < self.size.height/3)
          new_y = self.center.y - App.screen_height
          swipe_away_by_user_with_new_center [self.center.x, new_y]
          return
        end
      else
        if velocity.x > 0 && (self.center.x > 3*self.size.width/4)
          new_x = App.screen_width*2
          new_y = self.center.y + translation.y
          swipe_away_by_user_with_new_center [new_x, new_y]
          return
        end
        
        if velocity.x < 0 && (self.center.x < self.size.width/4)
          new_x = -App.screen_width
          new_y = self.center.y + translation.y
          swipe_away_by_user_with_new_center [new_x, new_y]
          return
        end
      end
      
      if self.origin.y != 0 || self.origin.x != 0        
        UIView.animateWithDuration(0.5,
                            delay:0.0,
                          options: UIViewAnimationCurveEaseInOut,
                       animations:(lambda do
                           self.transform = CGAffineTransformIdentity
                           self.origin    = @origin
                           self.alpha     = 1.0
                         end),
                       completion:(lambda do |finished|
                         end))
      end
    end
  end
  
  def remove_by_user
    Player.instance.ended_by_user

    remove
  end
  
  def remove
    track_playing_status_before_removing
    
    Player.instance.clear
    self.removeFromSuperview
  end
  
  def is_removed?
    @is_removed
  end
  
  def set_is_removed
    @is_removed = true
  end
  
  def increment_played_sec
    @played_sec += 1
  end
  
  def is_played?
    current_song_duration = Player.instance.current_song_duration
    if current_song_duration && current_song_duration > 10
      played_ratio = @played_sec / current_song_duration
      played_ratio > 0.75
    else
      false
    end
  end
  
  def track_playing_status_before_removing
    return if song_object.nil?
    
    if is_played?
      Robot.instance.send_played_event_with_song song_object.hash
    else
      Robot.instance.send_skip_event_with_song song_object.hash
    end
  end
  
  def swipe_away_by_user_with_new_center(new_center)
    UIView.animateWithDuration(0.5,
                          delay:0.0,
                        options: UIViewAnimationCurveEaseInOut,
                     animations:(lambda do
                         self.center = new_center
                       end),
                     completion:(lambda do |finished|
                         remove_by_user
                       end))
  end
  
  def swipe_away_automatically
    UIView.animateWithDuration(0.5,
                          delay:0.0,
                        options: UIViewAnimationCurveEaseInOut,
                     animations:(lambda do
                         if CBDirectionToDiscard == 'top'
                           self.origin = [self.origin.x, -self.size.height]
                         else
                           self.origin = [self.size.width, self.origin.y]
                         end
                       end),
                     completion:(lambda do |finished|
                         remove
                       end))
  end
  
end