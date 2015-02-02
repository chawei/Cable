class User
  @@current_user = nil
  
  attr_accessor :favorite_songs
  attr_accessor :bookmarked_events
  attr_accessor :recommended_events
  attr_accessor :streaming_songs
  
  def self.current
    if @@current_user.nil?
      @@current_user = User.new
    end
    @@current_user
  end
  
  def initialize
    @favorite_songs     ||= []
    @bookmarked_events  ||= []
    @recommended_events ||= []
    @streaming_songs    ||= []
    
    fetch_favorite_songs
    fetch_bookmarked_events
    fetch_streaming_songs
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
      :image_url => 'http://www.creativereview.co.uk/images/uploads/2009/05/radiohead.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers', 
      :source => 'youtube', :video_id => 'PeRxjkfTmVc',
      :image_url => 'http://ecx.images-amazon.com/images/I/41jZQc6jSwL._SS280.jpg'
    }, {
      :title => 'House of Cards', :subtitle => 'Radiohead', 
      :source => 'youtube', :video_id => '8nTFjVm9sTQ',
      :image_url => 'http://www.creativereview.co.uk/images/uploads/2009/05/radiohead.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers',
      :source => 'youtube', :video_id => 'PeRxjkfTmVc',
      :image_url => 'http://ecx.images-amazon.com/images/I/41jZQc6jSwL._SS280.jpg'
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
  
  def fetch_streaming_songs
    @streaming_songs = [{ 
      :title => "Don't Think Twice It's Alright [Bob Dylan 1962]", 
      :subtitle => "Bob Dylan", :source => 'youtube', :video_id => '2Ar7C6_L3Fg',
      :image_url => "http://i.ytimg.com/vi/2Ar7C6_L3Fg/mqdefault.jpg" 
    }, { 
      :title => "Radiohead - Lotus Flower", 
      :subtitle => "Radiohead", :source => 'youtube', :video_id => 'cfOa1a8hYP8',
      :image_url => "http://i.ytimg.com/vi/cfOa1a8hYP8/mqdefault.jpg" 
    }, { 
      :title => "Radiohead - Lotus Flower", 
      :subtitle => "Radiohead", :source => 'youtube', :video_id => 'cfOa1a8hYP8',
      :image_url => "http://i.ytimg.com/vi/cfOa1a8hYP8/mqdefault.jpg" 
    }]
  end
  
end