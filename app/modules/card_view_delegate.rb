module CardViewDelegate
  
  def add_player_view(player_view)
    @media_view.addSubview player_view
    #@media_view.sendSubviewToBack player_view
    player_view.frame = [[0, 0], [@media_view.size.width, @media_view.size.height]]
    
    # maybe should move to VideoPlayer when the movie_player_controller is created
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_and_toggle_play"
    tap_recognizer.numberOfTapsRequired = 1
    player_view.userInteractionEnabled = true
    player_view.subviews[0].addGestureRecognizer tap_recognizer

    @media_view.sendSubviewToBack @cover_art_view
    @media_view.bringSubviewToFront @media_info_view
  end
  
end