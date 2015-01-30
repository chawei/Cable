module CardViewDelegate
  
  def add_player_view(player_view)
    @media_view.addSubview player_view
    @media_view.sendSubviewToBack player_view
    player_view.frame = [[0, 0], [@media_view.size.width, @media_view.size.width/2]]
    
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_and_toggle_play"
    tap_recognizer.numberOfTapsRequired = 1
    player_view.userInteractionEnabled = true
    player_view.subviews[0].addGestureRecognizer tap_recognizer
  end
  
end