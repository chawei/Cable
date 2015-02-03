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
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def save(songs)
    @songs_ref.setValue songs
  end
  
  def pop_song
    song = @songs.shift
    save @songs
    
    song
  end
  
  def insert(song, index=1)
    @songs.insert(index, song)
    save @songs
  end
  
  def mock_songs
    [{
      :title => 'House of Cards (Rainbow Album 2010)', :subtitle => 'Radiohead', 
      :source => 'youtube', :video_id => '8nTFjVm9sTQ',
      :image_url => 'http://i.ytimg.com/vi/8nTFjVm9sTQ/hqdefault.jpg'
    }, {
      :title => '旺福-晴天娃娃', :subtitle => '', 
      :source => 'youtube', :video_id => 'zM46TDpw69U',
      :image_url => 'http://i.ytimg.com/vi/zM46TDpw69U/hqdefault.jpg'
    }, {
      :title => 'John Mayer - Waiting on the World to Change', :subtitle => 'John Mayer', 
      :source => 'youtube', :video_id => 'oBIxScJ5rlY',
      :image_url => 'http://i.ytimg.com/vi/oBIxScJ5rlY/hqdefault.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers',
      :source => 'youtube', :video_id => 'PeRxjkfTmVc',
      :image_url => 'http://i.ytimg.com/vi/PeRxjkfTmVc/hqdefault.jpg'
    }]
  end
  
  def mock_songs2
    [
      {"title"=>"Don't Think Twice It's Alright [Bob Dylan 1962]", "image_url"=>"http://i.ytimg.com/vi/2Ar7C6_L3Fg/hqdefault.jpg", "source"=>"youtube", "subtitle"=>"Bob Dylan", "video_id"=>"2Ar7C6_L3Fg"}, 
      {"title"=>"Radiohead - Lotus Flower", "image_url"=>"http://i.ytimg.com/vi/cfOa1a8hYP8/hqdefault.jpg", "source"=>"youtube", "subtitle"=>"Radiohead", "video_id"=>"cfOa1a8hYP8"}
    ]
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
  
end