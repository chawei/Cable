class Stream
  include Validation
  
  attr_accessor :songs
  
  def initialize(user_id)
    @songs      ||= []
    @stream_url ||= "#{FIREBASE_URL}/streams/#{user_id}"
    
    @stream_ref = Firebase.alloc.initWithUrl @stream_url
    @songs_ref  = @stream_ref.childByAppendingPath "objects"
    
    @is_initiated      = false
    @are_songs_updated = false
    
    @songs_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @songs = validate_objects snapshot.value.clone
        
        if @is_initiated == false
          App.card_stack_view.reload_card_views_if_necessary
          @is_initiated = true
        elsif @are_songs_updated == true
          update_and_play_card_views
        else
          update_card_views
        end
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def songs_updated
    @are_songs_updated = true
  end
  
  def save(songs)
    songs = validate_objects songs
    @songs_ref.setValue songs
  end
  
  def update_card_views
    # TODO: maybe use delegate?
    App.card_stack_view.update_card_views
  end
  
  def remove_first_song
    song = @songs.shift
    save @songs
    
    request_for_more_songs_if_necessary
  end
  
  def first_song
    @songs[0]
  end
  
  def pop_song
    song = @songs.shift
    save @songs
    
    request_for_more_songs_if_necessary
    
    song
  end
  
  def insert(song, index=1)
    @songs.insert(index, song)
    save @songs
  end
  
  def request_for_more_songs_if_necessary
    if @songs.length < 5
      Robot.instance.send_add_more_songs_request
    end
  end
  
  def update_and_play_card_views
    if App.card_stack_view.subviews.length == 0
      App.card_stack_view.reload_card_views_if_necessary
    else
      Player.instance.end_and_clear_by_user
      update_card_views
    end
    
    App.card_stack_view.play_top_card_view
  end
  
  # ===== For Testing =====
  def populate_mock_songs
    NSLog "populate_mock_songs"
    songs = mock_songs
    songs.each do |song|
      @songs << song
    end
    @songs_ref.setValue @songs
  end
  
  def mock_songs
    [{
      :title => 'House of Cards (Rainbow Album 2010)', :subtitle => 'Radiohead', 
      :source => 'youtube', :video_id => '8nTFjVm9sTQ',
      :image_url => 'http://i.ytimg.com/vi/8nTFjVm9sTQ/mqdefault.jpg'
    }, {
      :title => '旺福-晴天娃娃', :subtitle => '', 
      :source => 'youtube', :video_id => 'zM46TDpw69U',
      :image_url => 'http://i.ytimg.com/vi/zM46TDpw69U/mqdefault.jpg'
    }, {
      :title => 'John Mayer - Waiting on the World to Change', :subtitle => 'John Mayer', 
      :source => 'youtube', :video_id => 'oBIxScJ5rlY',
      :image_url => 'http://i.ytimg.com/vi/oBIxScJ5rlY/mqdefault.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers',
      :source => 'youtube', :video_id => 'PeRxjkfTmVc',
      :image_url => 'http://i.ytimg.com/vi/PeRxjkfTmVc/mqdefault.jpg'
    }]
  end
  
end