class HomeViewController < CBUIViewController  
  include RobotDelegate
  include ShareDelegate
  
  attr_accessor :logo_button
  attr_accessor :profile_button
  attr_accessor :events_button
  
  attr_accessor :card_stack_view
  attr_accessor :messages_view_controller
  attr_accessor :profile_view_controller
  attr_accessor :events_view_controller
  
  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.colorWithPatternImage UIImage.imageNamed("assets/pattern_background.png")
    
    set_buttons
    add_card_stack_view
    add_messages_view_controller
    add_message_box
    
    add_device_orientation_observer
    
    start
  end
  
  def start
    Robot.instance.delegate = self
    User.init
    
    UIApplication.sharedApplication.beginReceivingRemoteControlEvents
  end
  
  def say_hello_when_app_became_active
    unless Player.instance.is_playing?
      Robot.instance.say_hello
    end
  end
  
  def add_device_orientation_observer
    NSNotificationCenter.defaultCenter.addObserver self,
                 selector:"device_orientation_did_change_notification:",
                     name:UIDeviceOrientationDidChangeNotification,
                   object:nil
  end
  
  def add_card_stack_view
    @card_stack_view = CardStackView.alloc.initWithFrame self.view.frame
    view.addSubview @card_stack_view
    view.sendSubviewToBack @card_stack_view # necessary for iOS 7
    
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    @card_stack_view.addGestureRecognizer tap_recognizer
    
    add_default_message_view
  end
  
  def add_default_message_view
    @default_message_view = UIView.alloc.initWithFrame view.frame
    
    image_width  = CBDefaultButtonWidth
    image_height = CBDefaultButtonHeight
    image_view   = UIImageView.alloc.initWithFrame [[(view.size.width-image_width)/2, 0], [image_width, image_height]]
    image_view.image = CBLogoImage
    
    message_text = "No song cards on your desk.\nType what you want in the message box below."
    
    message_label               = UILabel.alloc.initWithFrame [[0, 0], [250, view.size.height]]
    message_label.text          = message_text
    message_label.textColor     = UIColor.whiteColor
    message_label.numberOfLines = 0
    message_label.textAlignment = NSTextAlignmentCenter
    message_label.font = UIFont.fontWithName(CBRegularFontName, size:18.0)
    message_label.sizeToFit
    
    origin_y = (view.size.height - image_view.size.height - message_label.size.height - 40)/2
    image_view.origin   = [image_view.origin.x, origin_y]
    message_label.frame = [[(view.size.width-message_label.size.width)/2, image_view.origin.y+image_view.size.height+10],
      message_label.size]
      
    @default_message_view.addSubview image_view
    @default_message_view.addSubview message_label
    
    view.addSubview @default_message_view
    view.sendSubviewToBack @default_message_view
  end
  
  def set_buttons
    top_margin = App.status_bar_height + CBDefaultMargin
    
    @logo_button = UIButton.buttonWithType UIButtonTypeCustom
    @logo_button.frame = [[(view.size.width-CBDefaultButtonWidth)/2, top_margin], 
      [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @logo_button.addTarget self, action:"press_logo_button", forControlEvents:UIControlEventTouchUpInside
    
    @profile_button = UIButton.buttonWithType UIButtonTypeCustom
    @profile_button.frame = [[CBDefaultMargin, top_margin], [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @profile_button.addTarget self, action:"toggle_profile:", forControlEvents:UIControlEventTouchUpInside
    
    @events_button = UIButton.buttonWithType UIButtonTypeCustom
    @events_button.frame = [[(view.size.width-CBDefaultMargin), top_margin], [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @events_button.addTarget self, action:"toggle_events:", forControlEvents:UIControlEventTouchUpInside
    
    logo_image = CBLogoImage
    @logo_button.setBackgroundImage logo_image, forState:UIControlStateNormal
    @logo_button.alpha = 1.0
    @logo_button.hidden = true
    
    user_icon_image = UIImage.imageNamed "assets/icon_user_profile"
    @profile_button.setBackgroundImage user_icon_image, forState:UIControlStateNormal
    @profile_button.alpha = CBInactiveAlphaValue
    
    events_image = UIImage.imageNamed "assets/icon_events"
    @events_button.setBackgroundImage events_image, forState:UIControlStateNormal
    @events_button.alpha = CBInactiveAlphaValue
    unless CBIsEventFeatureActive
      @events_button.userInteractionEnabled = false
      @events_button.alpha = 0.0
    end
    
    view.addSubview @logo_button
    view.addSubview @profile_button
    view.addSubview @events_button
  end
  
  def add_messages_view_controller
    @messages_view_controller = MessagesViewController.alloc.init_with_params({
      :max_width => self.view.size.width - CBDefaultMargin*2,
      :frame => [[0, App.status_bar_height], 
        [self.view.size.width, self.view.size.height-App.status_bar_height-CBMessageBoxHeight-CBDefaultMargin*2]]
    })
    @messages_view_controller.controller = self
    @messages_view_controller.collectionView.hidden = true
    self.view.addSubview @messages_view_controller.collectionView
  end
  
  def add_message_box
    @message_box = MessageBox.alloc.initWithFrame [[CBDefaultMargin, self.view.size.height-CBMessageBoxHeight-CBDefaultMargin], 
        [self.view.size.width-CBDefaultMargin*2, CBMessageBoxHeight]]
    @message_box.delegate = self
    self.view.addSubview @message_box
  end
  
  def message_box_did_send(message)
    @messages_view_controller.send_message(message)
    Robot.instance.send_message message
  end
  
  def update_frame_with_keyboard_height(keyboard_height)
    @messages_view_controller.update_frame_with_keyboard_height(keyboard_height)
  end
  
  def show_message_ui
    @card_stack_view.shrink
    @messages_view_controller.collectionView.hidden = false
    #self.view.bringSubviewToFront @messages_view_controller.collectionView
    #self.view.bringSubviewToFront @message_box
    
    #logo_button.hidden    = true
    profile_button.hidden = true
    events_button.hidden  = true
    @default_message_view.hidden = true
  end
  
  def hide_message_ui
    @card_stack_view.normalize
    @messages_view_controller.collectionView.hidden = true
    @message_box.dismiss_keyboard
    
    #logo_button.hidden    = false
    profile_button.hidden = false
    events_button.hidden  = false
    @default_message_view.hidden = false
  end
  
  def tap_background
    show_home_view
  end
  
  def show_home_view
    if @profile_view_controller
      @profile_view_controller.hide
    end
    
    if @events_view_controller
      @events_view_controller.hide
    end
    
    reset_buttons
    logo_button.alpha = 1.0
  end
  
  def press_logo_button
    tap_background
  end
  
  def toggle_profile(sender)
    if @profile_view_controller.nil?
      top_margin    = App.card_origin_y
      bottom_margin = CBHomeViewPadding
      left_margin   = CBHomeViewPadding
    
      #storyboard               = UIStoryboard.storyboardWithName("main", bundle: nil)
      #@profile_view_controller = storyboard.instantiateViewControllerWithIdentifier "ProfileViewController"
      @profile_view_controller = ProfileViewController.alloc.init
      @profile_view_controller.view.frame = [
        [view.frame.origin.x+left_margin, view.frame.origin.y+top_margin], 
        [view.size.width-left_margin*2, view.size.height-top_margin-bottom_margin]
      ]
    
      self.addChildViewController @profile_view_controller
      self.view.addSubview @profile_view_controller.view
      @profile_view_controller.view.hidden = true
      @profile_view_controller.view.alpha  = 0
      @profile_view_controller.didMoveToParentViewController self
    end
    
    reset_buttons
    @events_view_controller.view.hidden = true if @events_view_controller
    #@events_view_controller.hide if @events_view_controller
    if @profile_view_controller.view.isHidden
      @profile_view_controller.show
      profile_button.alpha = CBActiveAlphaValue
    else
      @profile_view_controller.hide
      profile_button.alpha = CBInactiveAlphaValue
      logo_button.alpha    = CBActiveAlphaValue
    end
  end
  
  def toggle_events(sender)
    if @events_view_controller.nil?
      top_margin    = App.card_origin_y
      bottom_margin = CBHomeViewPadding
      left_margin   = CBHomeViewPadding
      
      @events_view_controller = EventsViewController.alloc.init
      @events_view_controller.view.frame = [
        [view.frame.origin.x+left_margin, view.frame.origin.y+top_margin], 
        [view.size.width-left_margin*2, view.size.height-top_margin-bottom_margin]
      ]
    
      self.addChildViewController @events_view_controller
      self.view.addSubview @events_view_controller.view
      @events_view_controller.view.hidden = true
      @events_view_controller.view.alpha  = 0
      @events_view_controller.didMoveToParentViewController self
    end
    
    reset_buttons
    @profile_view_controller.view.hidden = true if @profile_view_controller
    #@profile_view_controller.hide if @profile_view_controller
    if @events_view_controller.view.isHidden
      @events_view_controller.show
      events_button.alpha = CBActiveAlphaValue
    else
      @events_view_controller.hide
      events_button.alpha = CBInactiveAlphaValue
      logo_button.alpha   = CBActiveAlphaValue
    end
  end
  
  def open_event_page(event_object)
    @event_view_controller = EventViewController.alloc.init_with_event_object(event_object)
    if CBShouldShowPageInFullScreen
      frame = [[0, view.size.height], [view.size.width, view.size.height]]
    else
      frame = [[CBDefaultMargin, view.size.height], 
        [view.size.width-CBDefaultMargin*2, view.size.height-CBDefaultMargin*2-App.status_bar_height]]
    end
    @event_view_controller.view.frame = frame
  
    self.addChildViewController @event_view_controller
    self.view.addSubview @event_view_controller.view
    @event_view_controller.didMoveToParentViewController self
    
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        if CBShouldShowPageInFullScreen
          origin = [0, 0]
        else
          origin = [CBDefaultMargin, App.status_bar_height+CBDefaultMargin]
        end
        @event_view_controller.view.origin = origin
        @event_view_controller.view.alpha  = CBActiveAlphaValue
      end), 
      completion:(lambda do |finished|
      end)
  end
  
  def reset_buttons
    logo_button.alpha    = CBInactiveAlphaValue
    profile_button.alpha = CBInactiveAlphaValue
    if CBIsEventFeatureActive
      events_button.alpha = CBInactiveAlphaValue
    end
  end
  
  def show_views
    @message_box.hidden = false
  end
  
  def hide_views
    @message_box.hidden = true
  end
  
  def remoteControlReceivedWithEvent(receivedEvent)
    if receivedEvent.type == UIEventTypeRemoteControl
      case receivedEvent.subtype
      when UIEventSubtypeRemoteControlPlay
        Player.instance.toggle_playing_status
      when UIEventSubtypeRemoteControlPause
        Player.instance.toggle_playing_status
      when UIEventSubtypeRemoteControlPreviousTrack
        Player.instance.play_from_the_beginning
      when UIEventSubtypeRemoteControlNextTrack
        App.card_stack_view.play_next_card_view_manually
      end
    end
  end
  
  def device_orientation_did_change_notification(notification)
    Player.instance.update_movie_screen
  end
  
  def showWebViewControllerWithUrl(url)
    webViewController = TOWebViewController.alloc.initWithURL url
    nav = UINavigationController.alloc.initWithRootViewController webViewController
    self.presentViewController nav, animated:true, completion:nil
  end
  
end