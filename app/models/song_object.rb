class SongObject
  
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :source
  attr_accessor :video_id
  attr_accessor :spotify_id
  attr_accessor :image_url
  attr_accessor :duration
  attr_accessor :tag
  
  def initialize(params)
    self.title      = params[:title]
    self.subtitle   = params[:subtitle]
    self.source     = params[:source]
    self.video_id   = params[:video_id]
    self.spotify_id = params[:spotify_id]
    self.image_url  = params[:image_url]
    self.duration   = params[:duration]
    self.tag        = params[:tag]
  end
  
  def id
    if is_from_youtube?
      youtube_id
    elsif is_from_spotify?
      spotify_id
    end
  end
  
  def is_from_youtube?
    self.source == 'youtube'
  end
  
  def is_from_spotify?
    self.source == 'spotify'
  end
  
  def can_be_played_in_spotify?
    is_from_spotify? && Player.instance.is_logged_in_spotify?
  end
  
  def youtube_id
    if is_from_youtube?
      video_id
    end
  end
  
  def hash
    {
      :title      => title,
      :subtitle   => subtitle,
      :source     => source,
      :video_id   => video_id,
      :spotify_id => spotify_id,
      :image_url  => image_url,
      :duration   => duration,
      :tag        => tag
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
  
  def cable_link
    link = "#{CBSiteHost}"
    if spotify_id && is_from_spotify?
      link = "#{CBSiteHost}/songs/#{spotify_id}?source=spotify"
    elsif youtube_id && is_from_youtube?
      link = "#{CBSiteHost}/songs/#{youtube_id}?source=youtube"
    end
    
    link
  end
  
  def copy_link
    #CableClient.instance.saveCopiedLinkObject(link, title:title)
    
    pasteboard = UIPasteboard.generalPasteboard
    pasteboard.string = cable_link
  end
end