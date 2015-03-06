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
  
  # This extends the touchable area by 20 pixels on the left and right and 15 pixels on the top and bottom.
  def pointInside(point, withEvent:event)
    bounds = self.bounds
    bounds = CGRectInset(bounds, -20, -15)
    return CGRectContainsPoint(bounds, point)
  end
end