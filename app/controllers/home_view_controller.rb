class HomeViewController < CBUIViewController
  extend IB
  
  outlet :logo_button
  outlet :profile_button
  outlet :events_button
  
  attr_accessor :card_views
  
  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.colorWithPatternImage UIImage.imageNamed("assets/pattern_background.png")
    
    add_background_view
    set_buttons
    
    card_views = []
    song1 = { :title => "Don't Think Twice It's Alright [Bob Dylan 1962]", 
              :subtitle => "Bob Dylan", :source => 'youtube', :video_id => '2Ar7C6_L3Fg',
              :image_url => "http://i.ytimg.com/vi/2Ar7C6_L3Fg/mqdefault.jpg" }
              
    song2 = { :title => "Radiohead - Lotus Flower", 
              :subtitle => "Radiohead", :source => 'youtube', :video_id => 'cfOa1a8hYP8',
              :image_url => "http://i.ytimg.com/vi/cfOa1a8hYP8/mqdefault.jpg" }
                    
    song_object = SongObject.new(song1)
    offset = CardView.default_height * 0.04
    card_view   = CardView.alloc.init_with_origin([CBHomeViewPadding, card_origin_y+offset])
    card_view.song_object = song_object
    card_view.transform = CGAffineTransformMakeScale(0.95, 0.95)
    view.addSubview card_view
    card_views << card_view
    
    song_object = SongObject.new(song2)
    card_view   = CardView.alloc.init_with_origin([CBHomeViewPadding, card_origin_y])
    card_view.song_object = song_object
    view.addSubview card_view
    card_views << card_view
  end
  
  def card_origin_y
    if App.is_small_screen?
      80
    else
      80
    end
  end
  
  def add_background_view
    background_view = UIView.alloc.initWithFrame self.view.frame
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    background_view.addGestureRecognizer tap_recognizer
    view.addSubview background_view
    view.sendSubviewToBack background_view
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
      top_margin    = card_origin_y
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
      top_margin    = card_origin_y
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
  
end