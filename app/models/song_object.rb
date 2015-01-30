class SongObject
  
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :source
  attr_accessor :video_id
  
  def initialize(params)
    self.title    = params[:title]
    self.subtitle = params[:subtitle]
    self.source   = params[:source]
    self.video_id = params[:video_id]
  end
  
  def is_from_youtube?
    self.source == 'youtube'
  end
  
  def youtube_id
    if is_from_youtube?
      video_id
    end
  end
  
  def liked_users
    [{
      :user_id => 123,
      :user_profile_url => "assets/test/kevin.jpg"
    }, {
      :user_id => 345,
      :user_profile_url => "assets/test/ann.jpg"
    }]
  end
end