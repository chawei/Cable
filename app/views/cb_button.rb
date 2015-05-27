class CBButton < UIButton
  
  # This extends the touchable area by 20 pixels on the left and right and 20 pixels on the top and bottom.
  def pointInside(point, withEvent:event)
    bounds = self.bounds
    bounds = CGRectInset(bounds, -20, -20)
    return CGRectContainsPoint(bounds, point)
  end
  
end