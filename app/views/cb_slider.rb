class CBSlider < UISlider
  
  def initWithFrame(frame)
    super
    
    trackRectForBounds [[0, 0], frame[1]]
    
    self
  end
  
  def trackRectForBounds(bounds)
    return bounds
  end
  
  def self.setup_appearance
    self.appearance.setMaximumTrackImage CBMaxTrackImage, forState:UIControlStateNormal
    self.appearance.setMinimumTrackImage CBMinTrackImage, forState:UIControlStateNormal
    self.appearance.setThumbImage CBTransparentImage, forState:UIControlStateNormal
    self.appearance.setThumbImage CBTransparentImage, forState:UIControlStateHighlighted
  end
end