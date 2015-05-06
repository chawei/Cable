class Itunes
  @@instance = nil
  
  def self.instance
    if @@instance.nil?
      @@instance = Itunes.new
    end
    return @@instance
  end
  
  def get_all_artists
    all_artist_query = MPMediaQuery.artistsQuery
    all_artists      = all_artist_query.collections
    
    all_artists.each do |artist|
      NSLog artist.representativeItem.valueForProperty(MPMediaItemPropertyArtist)
    end
  end
end