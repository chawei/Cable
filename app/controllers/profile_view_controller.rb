class ProfileViewController < CBUIViewController
  
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