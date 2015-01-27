class App
  
  def self.screen_width
    screen_rect  = UIScreen.mainScreen.bounds
    screen_width = screen_rect.size.width
  end
  
  def self.screen_height
    screen_rect   = UIScreen.mainScreen.bounds
    screen_height = screen_rect.size.height
  end
  
  def self.is_small_screen?
    screen_height <= 480.0
  end
  
end