module FocusedSliderView
  
  def show_focused_slider
    remove_pan_recognizer
    
    if @focused_slider_bg_view.nil?
      origin_x = self.origin.x + @media_view.origin.x + @media_info_view.origin.x + @time_slider_view.origin.x
      origin_y = self.origin.y + @media_view.origin.y + @media_info_view.origin.y + @time_slider_view.origin.y
      @focused_slider_bg_view = UIView.alloc.initWithFrame [[-origin_x, -origin_y], 
        [UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height]]
      @focused_slider_bg_view.backgroundColor = UIColor.colorWithRed(255.0/255.0, green:255.0/255.0, blue:255.0/255.0, alpha:1.0)
    end
    @time_slider_view.addSubview @focused_slider_bg_view
    @media_view.layer.zPosition       = CBMaxZPosition
    @time_slider_view.layer.zPosition = CBMaxZPosition
    @time_slider_view.sendSubviewToBack @focused_slider_bg_view
    
    emphasize_time_labels
  end

  def hide_focused_slider
    @media_view.layer.zPosition       = CBMediaViewZPosition
    @time_slider_view.layer.zPosition = CBDefaultZPosition
    
    if @focused_slider_bg_view
      @focused_slider_bg_view.removeFromSuperview
      reset_time_labels
    end
    
    add_pan_recognizer
  end
  
  def emphasize_time_labels
    # TODO: better solution?
    App.home_view_controller.hide_views
    
    UIView.animateWithDuration 0.3,
        delay:0.0,
        usingSpringWithDamping:0.5,
        initialSpringVelocity:0.0,
        options:0, 
        animations:(lambda do
          @played_time_label.transform = CGAffineTransformMakeScale(1.3, 1.3)
          @remain_time_label.transform = CGAffineTransformMakeScale(1.3, 1.3)
          @slider.transform            = CGAffineTransformMakeScale(1.0, 2.0)
        end),
        completion:nil
  end
  
  def reset_time_labels
    App.home_view_controller.show_views
    
    UIView.animateWithDuration 0.3,
        delay:0.0,
        usingSpringWithDamping:1.0,
        initialSpringVelocity:0.0,
        options:0, 
        animations:(lambda do
          @played_time_label.transform = CGAffineTransformMakeScale(1.0, 1.0)
          @remain_time_label.transform = CGAffineTransformMakeScale(1.0, 1.0)
          @slider.transform            = CGAffineTransformMakeScale(1.0, 1.0)
        end),
        completion:(lambda do |finished|
        end)
  end
end