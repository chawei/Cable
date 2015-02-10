class User
  @@current_user = nil
  
  attr_accessor :favorite_songs
  attr_accessor :bookmarked_events
  attr_accessor :recommended_events
  attr_reader   :stream
  
  def self.current
    if @@current_user.nil?
      @@current_user = User.new
    end
    @@current_user
  end
  
  def initialize
    user_id = 'david'
    @stream = Stream.new(user_id)
    
    @favorite_songs     ||= []
    @bookmarked_events  ||= []
    @recommended_events ||= []
    
    fetch_favorite_songs
    fetch_bookmarked_events
    #fetch_streaming_songs
  end
  
  def is_logged_in?
    true
  end
  
  def name
    "David Hsu"
  end
  
  def profile_status
    "12 favorite songs / 33 event bookmarkers"
  end
  
  def fetch_favorite_songs
    @favorite_songs = [{
      :title => 'House of Cards (Rainbow Album 2010)', :subtitle => 'Radiohead', 
      :source => 'youtube', :video_id => '8nTFjVm9sTQ',
      :image_url => 'http://i.ytimg.com/vi/8nTFjVm9sTQ/mqdefault.jpg'
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
  
  def fetch_bookmarked_events
    @bookmarked_events = [{
      :title => "The Von Trapps at The Chapel (January 28, 2015)", :subtitle => 'The Von Trapps', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/11997971.jpg'
    }, {
      :title => 'The View from the Afternoon', :subtitle => 'Arctic Monkeys', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/32760011.png'
    }, {
      :title => 'Paula Harris at Club Fox (January 28, 2015)', :subtitle => 'Paula Harris', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/75018252.jpg'
    }, {
      :title => 'Sunny Afternoon', :subtitle => 'The Kinks', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/86692565.png'
    }]
  end
  
end