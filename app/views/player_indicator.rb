class PlayerIndicator
  @@instance = nil
  
  attr_accessor :indicator
  
  def self.instance
    if @@instance.nil?
      @@instance = PlayerIndicator.new
    end
    
    @@instance
  end
  
  def build(frame)    
    @button = UIButton.buttonWithType UIButtonTypeCustom
    @button.frame = frame
    @button.layer.setCornerRadius CBDefaultButtonWidth/2
    @button.layer.setMasksToBounds true
    @button.addTarget self, action:"press_button", forControlEvents:UIControlEventTouchUpInside
    @button.backgroundColor = UIColor.colorWithRed 240/255.0, green:240/255.0, blue:240/255.0, alpha:0.3
    @button.hidden = true
    
    @indicator = NAKPlaybackIndicatorView.alloc.initWithFrame [
      [(CBDefaultButtonWidth-13)/2, (CBDefaultButtonHeight-12)/2], [13, 12]]
    @indicator.state = NAKPlaybackIndicatorViewStatePaused
    @indicator.tintColor = UIColor.whiteColor
    
    @button.addSubview @indicator
    
    self
  end
  
  def view
    @button
  end
  
  def hide
    @button.hidden = true
  end
  
  def show
    if Player.instance.is_playing?
      set_as_playing
    else
      set_as_pause
    end
    
    @button.hidden = false
  end
  
  def set_as_playing
    @indicator.state = NAKPlaybackIndicatorViewStatePlaying
  end
  
  def set_as_pause
    @indicator.state = NAKPlaybackIndicatorViewStatePaused
  end
  
  def press_button
    
  end
  
end