class Cloud
  
  @@instance = nil
  
  def self.instance
    if @@instance.nil?
      @@instance = Cloud.new
    end
    @@instance
  end
  
  def save_played_song(song_object)
    save_custom_object("PlayedSong", song_object:song_object)
  end
  
  def save_custom_object(name, song_object:song_object)
    custom_object = PFObject.objectWithClassName(name)
    custom_object.setObject song_object.id, forKey:'uniqueId'
    custom_object.setObject song_object.source, forKey:'sourceFrom'
    custom_object.setObject song_object.title, forKey:'title'
    custom_object.setObject song_object.subtitle, forKey:'subtitle'
    custom_object.setObject Time.now.hour, forKey:'localHour'
    
    point = PFGeoPoint.geoPointWithLatitude Time.now.hour, longitude:0.0
    custom_object.setObject point, forKey:'localHourPoint'
    
    if song_object.duration
      custom_object.setObject song_object.duration.to_i, forKey:'duration'
    end
    if song_object.image_url
      custom_object.setObject song_object.image_url, forKey:'image_url'
    end
    if song_object.tag
      custom_object.setObject song_object.tag, forKey:'query'
    end
    if PFUser.currentUser
      custom_object.setObject PFUser.currentUser, forKey:'fromUser'
    end
    
    custom_object.saveInBackground
  end
end