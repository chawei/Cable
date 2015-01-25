class HomeViewController < CBUIViewController
  extend IB
  
  outlet :profile_button
  outlet :events_button
  
  attr_reader :profile_view_controller
  
  def open_profile(sender)
    if @profile_view_controller.nil?
      top_margin    = 100
      bottom_margin = 20
      left_margin   = 20
    
      storyboard              = UIStoryboard.storyboardWithName("main", bundle: nil)
      @profile_view_controller = storyboard.instantiateViewControllerWithIdentifier "ProfileViewController"
      @profile_view_controller.view.frame = [
        [view.frame.origin.x+left_margin, view.frame.origin.y+top_margin], 
        [view.size.width-left_margin*2, view.size.height-top_margin-bottom_margin]]
    
      self.addChildViewController @profile_view_controller
      self.view.addSubview @profile_view_controller.view
      @profile_view_controller.view.hidden = true
      @profile_view_controller.view.alpha  = 0
      @profile_view_controller.didMoveToParentViewController self
    end
    
    @profile_view_controller.toggle_display
  end
  
  def open_events(sender)
    NSLog "Open events"
  end
  
end