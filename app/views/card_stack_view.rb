class CardStackView < UIView
  
  def willRemoveSubview(subview)
    super
    
    reload_card_views_if_necessary(4)
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
        song = User.current.stream.pop_song
        song_object = SongObject.new song
        add_card_view_at_bottom_with_song_object song_object
      end
    end
    update_card_views
  end
  
  def play_top_card_view
    if top_card_view = subviews[-1]
      top_card_view.tap_and_toggle_play
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
  
end