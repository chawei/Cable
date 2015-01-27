class HomeViewController < CBUIViewController
  extend IB
  
  outlet :profile_button
  outlet :events_button
  
  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.colorWithPatternImage UIImage.imageNamed("assets/pattern_background.png")
    
    set_buttons
    
    params      = { :title => "Don't Think Twice It's Alright [Bob Dylan 1962]", 
                    :subtitle => "Bob Dylan / 3 min 29 sec", :source => 'spotify' }
                    
    song_object = SongObject.new(params)
    offset = CardView.default_height * 0.04
    card_view   = CardView.alloc.init_with_origin([20, card_origin_y+offset])
    card_view.song_object = song_object
    card_view.transform = CGAffineTransformMakeScale(0.95, 0.95)
    view.addSubview card_view
    
    song_object = SongObject.new(params)
    card_view   = CardView.alloc.init_with_origin([20, card_origin_y])
    card_view.song_object = song_object
    view.addSubview card_view
  end
  
  def card_origin_y
    if App.is_small_screen?
      80
    else
      80
    end
  end
  
  def set_buttons
    user_icon_image = UIImage.imageNamed "assets/icon_user_profile"
    profile_button.setBackgroundImage user_icon_image, forState:UIControlStateNormal
    
    events_image = UIImage.imageNamed "assets/icon_events"
    events_button.setBackgroundImage events_image, forState:UIControlStateNormal
  end
  
  def open_profile(sender)
    if @profile_view_controller.nil?
      top_margin    = card_origin_y
      bottom_margin = 20
      left_margin   = 20
    
      storyboard               = UIStoryboard.storyboardWithName("main", bundle: nil)
      @profile_view_controller = storyboard.instantiateViewControllerWithIdentifier "ProfileViewController"
      @profile_view_controller.view.frame = [
        [view.frame.origin.x+left_margin, view.frame.origin.y+top_margin], 
        [view.size.width-left_margin*2, view.size.height-top_margin-bottom_margin]]
    
      self.addChildViewController @profile_view_controller
      self.view.addSubview @profile_view_controller.view
      @profile_view_controller.view.hidden = true
      @profile_view_controller.view.alpha  = 0
      @profile_view_controller.didMoveToParentViewController self
    end
    
    @profile_view_controller.toggle_display
  end
  
  def open_events(sender)
    NSLog "Open events"
  end
  
end