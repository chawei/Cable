module Style
  
  def apply_rounded_corner
    if self.respond_to?('view')
      layer = self.view.layer
    else
      layer = self.layer
    end
    
    layer.setCornerRadius CBRoundedCornerRadius
    layer.setShadowColor UIColor.blackColor.CGColor
    layer.setShadowOpacity 0.24
    layer.setShadowRadius 4.0
    layer.setShadowOffset CGSizeMake(0, 1.0)
    layer.shouldRasterize = true
    # Don't forget the rasterization scale
    # I spent days trying to figure out why retina display assets weren't working as expected
    layer.rasterizationScale = UIScreen.mainScreen.scale
  end
  
  def apply_rounded_corner_on_view(view)    
    view.layer.setCornerRadius CBRoundedCornerRadius
    view.layer.setShadowColor UIColor.blackColor.CGColor
    view.layer.setShadowOpacity 0.24
    view.layer.setShadowRadius 4.0
    view.layer.setShadowOffset CGSizeMake(0, 1.0)
    view.layer.shouldRasterize = true
    # Don't forget the rasterization scale
    # I spent days trying to figure out why retina display assets weren't working as expected
    view.layer.rasterizationScale = UIScreen.mainScreen.scale
  end
  
end