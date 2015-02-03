class HomeViewController < CBUIViewController
  extend IB
  
  outlet :logo_button
  outlet :profile_button
  outlet :events_button
  
  attr_accessor :card_stack_view
  
  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.colorWithPatternImage UIImage.imageNamed("assets/pattern_background.png")
    
    add_card_stack_view
    set_buttons
    
    add_message_box
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
  
  def add_message_box
    
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
      profile_button.alpha = 1.0
    else
      @profile_view_controller.hide
      profile_button.alpha = CBInactiveAlphaValue
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
      events_button.alpha = 1.0
    else
      @events_view_controller.hide
      events_button.alpha = CBInactiveAlphaValue
    end
  end
  
  def reset_buttons
    logo_button.alpha    = CBInactiveAlphaValue
    profile_button.alpha = CBInactiveAlphaValue
    events_button.alpha  = CBInactiveAlphaValue
  end
  
  def handle_response(response)
    NSLog response[:message]
  end
  
end