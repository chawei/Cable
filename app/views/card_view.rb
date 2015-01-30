class CardView < UIView
  include Style
  include CardViewDelegate
  
  def init_with_origin(origin)
    @song_object = nil
    
    card_left_margin = CBDefaultMargin
    card_view_width  = App.screen_width - card_left_margin*2
    
    initWithFrame [origin, [card_view_width, card_height]]
    @origin       = self.frame.origin
    @lastLocation = self.center
    
    setup_view
    set_player
    
    self
  end
  
  def self.default_height
    if App.is_small_screen?
      320
    else
      if App.screen_height > 660.0
        450
      else
        400
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
    self.addSubview @media_source_button
    
    mv_top_margin = card_top_padding + msb_width/2
    @media_view = UIView.alloc.initWithFrame([[0, mv_top_margin], [card_width, media_view_height]])
    @media_view.backgroundColor = UIColor.blackColor
    self.addSubview @media_view
    self.sendSubviewToBack @media_view
    
    #add_labels_after_view @media_view
    add_media_info_view_on_view @media_view
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
  
  def add_media_info_view_on_view(view)
    @media_info_view = UIView.alloc.initWithFrame([[0, 0], view.size])
    @media_info_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.2
    
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
      [card_width-CBDefaultMargin*2, 15]]
    
    @played_time_label = UILabel.alloc.initWithFrame [[0, 0], [CBTimeLabelWidth, 15]]
    @played_time_label.numberOfLines = 1
    @played_time_label.textAlignment = NSTextAlignmentLeft
    @played_time_label.textColor     = gray_color
    @played_time_label.setFont UIFont.fontWithName(CBLightFontName, size:10.0)
    @played_time_label.text = "--:--"
    @time_slider_view.addSubview @played_time_label
    
    @remain_time_label = UILabel.alloc.initWithFrame [[@time_slider_view.size.width-CBTimeLabelWidth, 0], [CBTimeLabelWidth, 15]]
    @remain_time_label.numberOfLines = 1
    @remain_time_label.textAlignment = NSTextAlignmentRight
    @remain_time_label.textColor     = gray_color
    @remain_time_label.setFont UIFont.fontWithName(CBLightFontName, size:10.0)
    @remain_time_label.text = "--:--"
    @time_slider_view.addSubview @remain_time_label
    
    CBSlider.setup_appearance
    @slider = CBSlider.alloc.initWithFrame [[@played_time_label.size.width, 2], 
      [@time_slider_view.size.width-CBTimeLabelWidth*2, CBSliderHeight]]
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
    pan_recognizer = UIPanGestureRecognizer.alloc.initWithTarget self, action:"detect_pan:"
    self.addGestureRecognizer pan_recognizer
  end
  
  def add_tap_recognizer
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_and_toggle_play"
    self.addGestureRecognizer tap_recognizer
  end
  
  def set_player
    Player.instance.delegate = self
    if @slider
      Player.instance.set_slider @slider
    end
  end
  
  def tap_and_toggle_play
    if @song_object
      Player.instance.toggle_playing_status_on_object @song_object
    end
  end
  
  def create_liked_users_view
    @liked_users_view = UIView.alloc.init
      
    if song_object  
      liked_users = song_object.liked_users
      liked_users.each_index do |index|
        user_pic_url     = liked_users[index][:user_profile_url]
        user_image       = UIImage.imageNamed user_pic_url
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
    end
  end
  
  def add_liked_users_view
    if App.is_small_screen?
      add_liked_users_at_the_bottom
    else
      add_liked_users_after_view @time_slider_view
    end
  end
  
  def add_liked_users_at_the_bottom
    create_liked_users_view
    
    @liked_users_view.frame = [[card_padding, self.size.height-32-CBDefaultMargin],
      [card_width-card_padding*2, 32]]
    self.addSubview @liked_users_view
    self.sendSubviewToBack @liked_users_view
  end
  
  def add_liked_users_after_view(view)    
    create_liked_users_view
    
    @liked_users_view.frame = [[card_padding, view.frame.origin.y+view.size.height+CBDefaultMargin],
      [card_width-card_padding*2, 32]]
    @media_info_view.addSubview @liked_users_view
    @media_info_view.sendSubviewToBack @liked_users_view
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
    add_liked_users_view
    update_media_info_view
  end
  
  def update_source_button
    if @song_object.source == 'spotify'
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
        @liked_users_view.frame.origin.y+@liked_users_view.size.height+CBDefaultMargin]
    end
    
    new_origin_y = @media_view.size.height-new_size[1]
    @media_info_view.frame = [[0, new_origin_y], new_size]
  end
  
  def update_time_labels(played_sec_str, remain_sec_str)
    @played_time_label.text = played_sec_str
    @remain_time_label.text = remain_sec_str
  end
  
  def toggle_like_button
    current_state_image = @like_button.imageForState UIControlStateNormal
    if current_state_image == CBLikeIconImage
      @like_button.setImage CBLikedIconImage, forState:UIControlStateNormal
    else
      @like_button.setImage CBLikeIconImage, forState:UIControlStateNormal
    end
  end
  
  def press_share_button
    NSLog "press_share_button"
  end
  
  def press_user_button
    
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
      
      rads = 0.1/180.0 * Math::PI * translation.x
      new_transform  = CGAffineTransformMakeRotation rads
      self.transform = new_transform
      
      self.alpha = 1 - (translation.x).abs/1000

      self.center = CGPointMake(@lastLocation.x + translation.x, @lastLocation.y + translation.y)
    end
    
    if recognizer.state == UIGestureRecognizerStateEnded
      @direction = nil
      
      if velocity.x > 0 && (self.center.x > 3*self.size.width/4)
        new_x = App.screen_width*2
        new_y = self.center.y + translation.y
        discard_card_with_new_center [new_x, new_y]
        return
      end
      
      if velocity.x < 0 && (self.center.x < self.size.width/4)
        new_x = -App.screen_width
        new_y = self.center.y + translation.y
        discard_card_with_new_center [new_x, new_y]
        return
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
  
  def discard_card_with_new_center(new_center)
    UIView.animateWithDuration(0.5,
                          delay:0.0,
                        options: UIViewAnimationCurveEaseInOut,
                     animations:(lambda do
                         self.center = new_center
                       end),
                     completion:(lambda do |finished|
                       end))
  end
end