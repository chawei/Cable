class SongObject
  
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :source
  attr_accessor :video_id
  attr_accessor :image_url
  attr_accessor :duration
  attr_accessor :tag
  
  def initialize(params)
    self.title     = params[:title]
    self.subtitle  = params[:subtitle]
    self.source    = params[:source]
    self.video_id  = params[:video_id]
    self.image_url = params[:image_url]
    self.duration  = params[:duration]
    self.tag       = params[:tag]
  end
  
  def id
    if is_from_youtube?
      youtube_id
    end
  end
  
  def is_from_youtube?
    self.source == 'youtube'
  end
  
  def youtube_id
    if is_from_youtube?
      video_id
    end
  end
  
  def hash
    {
      :video_id  => video_id,
      :title     => title,
      :subtitle  => subtitle,
      :source    => source,
      :image_url => image_url,
      :duration  => duration
    }
  end
  
  def liked_users
    [{
      :user_id => 123,
      :user_profile_url => "http://graph.facebook.com/10152803559949434/picture?width=64&height=64"
    }, {
      :user_id => 345,
      :user_profile_url => "http://graph.facebook.com/10152673628547503/picture?width=64&height=64"
    }]
    
    []
  end
  
  def copy_link
    link = "#{CBSiteHost}/songs/#{video_id}"
    #CableClient.instance.saveCopiedLinkObject(link, title:title)
    
    pasteboard = UIPasteboard.generalPasteboard
    pasteboard.string = link
  end
end