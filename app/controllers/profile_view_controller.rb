class ProfileViewController < CBUIViewController
  extend IB
  
  outlet :setting_button
  
  include Style
  
  def viewDidLoad
    super
    
    apply_rounded_corner
    
    setting_button.setImage CBShareIconImage, forState:UIControlStateNormal
  end
  
  def toggle_display
    if view.isHidden
      view.alpha  = 0
      view.hidden = false
      UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
          view.alpha = 1
        end), 
        completion:nil
    else
      UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
          view.alpha = 0
        end), 
        completion:(lambda do |finished|
          view.hidden = true
        end)
    end
  end
end