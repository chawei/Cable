module ViewAnimation
  
  def show_view(view)
    if @original_origin.nil?
      @original_origin = view.origin
    end
    
    view.origin = [view.origin.x, -view.size.height]
    view.alpha  = 1.0
    view.hidden = false
    
    UIView.animateWithDuration 0.25,
      delay:0.0,
      usingSpringWithDamping:0.8,
      initialSpringVelocity:0.0,
      options:0, 
      animations:(lambda do
        view.origin = @original_origin
        view.alpha  = 1.0
      end),
      completion:nil
  end
  
  def hide_view(view)
    UIView.animateWithDuration 0.25,
      delay:0.0,
      usingSpringWithDamping:1.0,
      initialSpringVelocity:0.0,
      options:0, 
      animations:(lambda do
        view.origin = [view.origin.x, -view.size.height]
        view.alpha  = 1.0
      end),
      completion:(lambda do |finished|
        view.hidden = true
      end)
  end
  
  def fade_in_view(view)
    view.alpha  = 0
    view.hidden = false
    UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
        view.alpha = 1
      end), 
      completion:nil
  end
  
  def fade_out_view(view)
    UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
        view.alpha = 0
      end), 
      completion:(lambda do |finished|
        view.hidden = true
      end)
  end
end