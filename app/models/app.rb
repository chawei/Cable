class App
  
  def self.version
    NSBundle.mainBundle.infoDictionary["CFBundleVersion"]
  end
  
  def self.screen_width
    screen_rect  = UIScreen.mainScreen.bounds
    screen_width = screen_rect.size.width
  end
  
  def self.screen_height
    screen_rect   = UIScreen.mainScreen.bounds
    screen_height = screen_rect.size.height
  end
  
  def self.status_bar_height
    UIApplication.sharedApplication.statusBarFrame.size.height
  end
  
  def self.card_origin_y
    if App.is_small_screen?
      80
    else
      85
    end
  end
  
  def self.is_small_screen?
    screen_height <= 480.0
  end
  
  def self.home_view_controller
    if @home_view_controller.nil?
      @home_view_controller = HomeViewController.alloc.init
    end
    @home_view_controller
  end
  
  def self.card_stack_view
    home_view_controller.card_stack_view
  end
  
  def self.messages_view_controller
    home_view_controller.messages_view_controller
  end
  
  def self.profile_view_controller
    home_view_controller.profile_view_controller
  end
  
  def self.events_view_controller
    home_view_controller.events_view_controller
  end
  
  def self.message_box
    home_view_controller.message_box
  end
  
  def self.play_object_by_user(object)
    Player.instance.end_and_clear_by_user
    play_object(object)
  end
  
  def self.play_object(object)
    User.current.stream.insert(object, 0)
    User.current.stream.songs_updated
    #song_object = SongObject.new object
    #card_stack_view.add_card_view_on_top_with_song_object(song_object)
    #card_stack_view.play_top_card_view
  end
  
  def self.show_event_page(object)
    home_view_controller.open_event_page(object)
  end
  
  def self.popup_sharing_options
    #PopUpView.alloc.init_with_origin(origin, with_song_object:song_object)
  end
  
end