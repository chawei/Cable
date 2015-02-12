class CardStackView < UIView
  
  def willRemoveSubview(subview)
    super
    
    unless subview.is_removed?
      subview.set_is_removed
      subview.removeFromSuperview
      
      User.current.stream.remove_first_song
      reload_card_views_if_necessary(3)
      
      play_top_card_view
    end
  end
  
  def initialize_card_views
    User.current.stream.fetch do |songs|
      # TODO: review this part (performance)
      reload_card_views_if_necessary
    end
  end
  
  def reload_card_views_if_necessary(max_card_view_num=3)
    return if subviews.length >= max_card_view_num
    
    while subviews.length < max_card_view_num
      if User.current.stream.songs.length == 0
        break
      else
        song = User.current.stream.first_song
        song_object = SongObject.new song
        add_card_view_at_bottom_with_song_object song_object
      end
    end
    update_card_views
  end
  
  def top_card_view
    subviews[-1]
  end
  
  def play_top_card_view
    if top_card_view
      top_card_view.play
    end
  end
  
  def play_next_card_view_manually
    if top_card_view
      top_card_view.remove_by_user
    end
  end
  
  def add_card_view_on_top_with_song_object(song_object)
    card_view = add_card_view_with_song_object song_object
    update_card_views
  end
  
  def add_card_view_at_bottom_with_song_object(song_object)
    card_view = add_card_view_with_song_object song_object
    self.sendSubviewToBack card_view
    update_card_view(card_view)
  end
  
  def add_card_view_with_song_object(song_object)
    card_view = CardView.alloc.init_with_origin([CBHomeViewPadding, App.card_origin_y])
    card_view.song_object = song_object
    self.addSubview card_view
    
    card_view
  end
  
  def offset_of_card_order(card_order)
    factor = 0
    if card_order >= 0 && card_order <= 3
      factor = card_order-1
    elsif card_order > 3
      factor = 2
    end
    CardView.default_height * 0.07 * factor
  end
  
  def transform_of_card_order(card_order)
    factor = 0
    if card_order >= 0 && card_order <= 3
      factor = card_order-1
    elsif card_order > 3
      factor = 2
    end
    
    scale_ratio = 1.0 - factor*0.05
    CGAffineTransformMakeScale(scale_ratio, scale_ratio)
  end
  
  def card_order_of_card_view(card_view)
    subviews.length - subviews.index(card_view)
  end
  
  def update_card_view(card_view)
    card_order        = card_order_of_card_view(card_view)
    offset            = offset_of_card_order(card_order)
    new_card_origin_y = App.card_origin_y + offset
    
    # have to update transform first, otherwise position will get wrong
    card_view.transform = transform_of_card_order(card_order)
    card_view.origin    = [card_view.origin.x, new_card_origin_y]
    
    assign_song_object_to_card_view(card_view)
  end
  
  def assign_song_object_to_card_view(card_view)
    card_order = card_order_of_card_view(card_view)
    song       = User.current.stream.songs[card_order-1]
    if song
      song_object = SongObject.new song
      card_view.song_object = song_object
    end
  end
  
  def update_card_views
    subviews.each do |card_view|
      UIView.animateWithDuration(0.2,
                          delay:0.0,
                        options: UIViewAnimationCurveEaseInOut,
                     animations:(lambda do
                         update_card_view card_view
                       end),
                     completion:(lambda do |finished|
                       end))
    end
  end
  
  def shrink
    UIView.animateWithDuration 0.3,
        delay:0.0,
        usingSpringWithDamping:1.0,
        initialSpringVelocity:0.0,
        options:0, 
        animations:(lambda do
          self.transform = CGAffineTransformMakeScale(0.9, 0.9)
          self.alpha     = 0.2
        end),
        completion:nil
  end
  
  def normalize
    UIView.animateWithDuration 0.3,
        delay:0.0,
        usingSpringWithDamping:0.5,
        initialSpringVelocity:0.0,
        options:0, 
        animations:(lambda do
          self.transform = CGAffineTransformMakeScale(1.0, 1.0)
          self.alpha     = 1.0
        end),
        completion:nil
  end
  
end