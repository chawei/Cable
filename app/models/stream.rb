class Stream
  
  attr_accessor :songs
  
  def initialize(user_id)
    @songs      ||= []
    @stream_url ||= "https://burning-torch-7761.firebaseio.com/streams/#{user_id}"
    
    @stream_ref = Firebase.alloc.initWithUrl @stream_url
    @songs_ref  = @stream_ref.childByAppendingPath "songs"
    @swiped_ref = @stream_ref.childByAppendingPath "swiped"
    
    @songs_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @songs = snapshot.value.clone
        
        #NSLog "@is_sync: #{@is_sync}"
        #if @is_sync
        #  App.messages_view_controller.reset_message_objects
        #  Robot.instance.clear_message_queue
        #  Robot.instance.queue_message_text "Someone is using your stream!"
        #  @is_sync = false
        #else
        #  @songs = snapshot.value.clone
        #  @is_sync = true
        #end
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def save(songs)
    NSLog "save songs"
    #@is_sync = false
    @songs_ref.setValue songs
    
    update_ui
  end
  
  def update_ui
    # TODO: maybe use delegate?
    App.card_stack_view.update_card_views
    # App.card_stack_view.play_top_card_view # this is evil, will dup the playing action
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
      populate_mock_songs
    end
  end
  
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
  
  def fetch(&block)
    @songs_ref.observeSingleEventOfType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @songs = snapshot.value.clone
        if block
          block.call @songs
        end
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def connect(stream_url)
    @stream_url = stream_url
    @stream_ref = Firebase.alloc.initWithUrl @stream_url
    @songs_ref  = @stream_ref.childByAppendingPath "songs"
    
    @songs_ref.observeSingleEventOfType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @songs = snapshot.value.clone
        update_ui
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
end