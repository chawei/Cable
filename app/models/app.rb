class App
  
  def self.screen_width
    screen_rect  = UIScreen.mainScreen.bounds
    screen_width = screen_rect.size.width
  end
  
  def self.screen_height
    screen_rect   = UIScreen.mainScreen.bounds
    screen_height = screen_rect.size.height
  end
  
  
  def self.card_origin_y
    if App.is_small_screen?
      80
    else
      80
    end
  end
  
  def self.is_small_screen?
    screen_height <= 480.0
  end
  
  def self.home_view_controller
    if @home_view_controller.nil?
      storyboard = UIStoryboard.storyboardWithName("main", bundle: nil)
      @home_view_controller = storyboard.instantiateInitialViewController
    end
    @home_view_controller
  end
  
  def self.card_stack_view
    home_view_controller.card_stack_view
  end
  
end