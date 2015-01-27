class SongObject
  
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :source
  
  def initialize(params)
    self.title    = params[:title]
    self.subtitle = params[:subtitle]
    self.source   = params[:source]
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