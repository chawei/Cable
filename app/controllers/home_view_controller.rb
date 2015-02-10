class HomeViewController < CBUIViewController
  extend IB
  
  outlet :logo_button
  outlet :profile_button
  outlet :events_button
  
  attr_accessor :card_stack_view
  attr_accessor :messages_view_controller
  
  def viewWillAppear(animated)
    super
    
  end
  
  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.colorWithPatternImage UIImage.imageNamed("assets/pattern_background.png")
    
    add_card_stack_view
    set_buttons
    
    add_messages_view_controller
    add_message_box
    
    start
  end
  
  def start
    Robot.instance.delegate = self
    
    unless User.current.is_logged_in?
      Robot.instance.say_hello
    end
  end
  
  def add_card_stack_view
    @card_stack_view = CardStackView.alloc.initWithFrame self.view.frame
    view.addSubview @card_stack_view
    view.sendSubviewToBack @card_stack_view # necessary for iOS 7
    
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    @card_stack_view.addGestureRecognizer tap_recognizer
    
    @card_stack_view.initialize_card_views
  end
  
  def set_buttons
    logo_image = UIImage.imageNamed "assets/icon_logo"
    logo_button.setBackgroundImage logo_image, forState:UIControlStateNormal
    logo_button.alpha = 1.0
    
    user_icon_image = UIImage.imageNamed "assets/icon_user_profile"
    profile_button.setBackgroundImage user_icon_image, forState:UIControlStateNormal
    profile_button.alpha = CBInactiveAlphaValue
    
    events_image = UIImage.imageNamed "assets/icon_events"
    events_button.setBackgroundImage events_image, forState:UIControlStateNormal
    events_button.alpha = CBInactiveAlphaValue
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
    request = { :message => message, :mode => 'message' }
    Robot.instance.listen request
    @messages_view_controller.send_message(message)
  end
  
  def update_frame_with_keyboard_height(keyboard_height)
    @messages_view_controller.update_frame_with_keyboard_height(keyboard_height)
  end
  
  def show_message_ui
    @card_stack_view.shrink
    @messages_view_controller.collectionView.hidden = false
    
    logo_button.hidden    = true
    profile_button.hidden = true
    events_button.hidden  = true
  end
  
  def hide_message_ui
    @card_stack_view.normalize
    @messages_view_controller.collectionView.hidden = true
    @message_box.dismiss_keyboard
    
    logo_button.hidden    = false
    profile_button.hidden = false
    events_button.hidden  = false
  end
  
  def tap_background
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
  
  def open_event_page(event_object={})
    @event_view_controller = EventViewController.alloc.init_with_event_object(event_object)
    @event_view_controller.view.frame = [[CBDefaultMargin, view.size.height], 
      [view.size.width-CBDefaultMargin*2, view.size.height-CBDefaultMargin*2-App.status_bar_height]]
    #@event_view_controller.view.alpha  = CBInactiveAlphaValue
  
    self.addChildViewController @event_view_controller
    self.view.addSubview @event_view_controller.view
    @event_view_controller.didMoveToParentViewController self
    
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        @event_view_controller.view.origin = [CBDefaultMargin, App.status_bar_height+CBDefaultMargin]
        @event_view_controller.view.alpha  = CBActiveAlphaValue
      end), 
      completion:(lambda do |finished|
      end)
  end
  
  def reset_buttons
    logo_button.alpha    = CBInactiveAlphaValue
    profile_button.alpha = CBInactiveAlphaValue
    events_button.alpha  = CBInactiveAlphaValue
  end
  
  def handle_response(response)
    message_object = {
      :type => 'text',
      :text => response[:message],
      :time_text => DateFormatter.toHumanReadableTime(Time.now),
      :direction => 'left'
    }
    Robot.instance.queue_message_object(message_object)
  end
  
  def show_robot_message(message_object)
    show_message_ui
    @messages_view_controller.show_message_object(message_object)
  end
  
end