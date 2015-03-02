class User
  include FacebookAuth
  
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
  
  def self.init
    current
  end
  
  def self.login_as_anonymous_with_block(block)
    PFAnonymousUtils.logInWithBlock(lambda do |user, error|
      if error
        NSLog "Anonymous login failed."
      else
        NSLog "Anonymous user logged in."
      end
      
      if block
        block.call(user)
      end
    end)
  end
  
  def initialize    
    @favorite_songs     ||= []
    @bookmarked_events  ||= []
    @recommended_events ||= []
    
    @firebase_ref = Firebase.alloc.initWithUrl FIREBASE_URL
    fetch_auth_data_and_establish_data_refs
  end
  
  def logout
    PFUser.logOut
    fetch_auth_data_and_establish_data_refs
  end
  
  def is_logged_in?
    PFUser.currentUser != nil && !is_anonymous?
  end
  
  def is_anonymous?
    PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser)
  end
  
  def fetch_auth_data_and_establish_data_refs
    if PFUser.currentUser != nil
      establish_data_refs
    else
      User.login_as_anonymous_with_block(lambda do |user|
        establish_data_refs
      end)
    end
  end
  
  def establish_data_refs
    initialize_stream
    
    establish_favorites_ref
    establish_bookmarked_events_ref
    fetch_recommended_events
  end
  
  def initialize_stream
    @stream = Stream.new(user_id)
  end
  
  def auth_data
    @auth_data
  end
  
  def user_id
    if PFUser.currentUser
      PFUser.currentUser.objectId
    else
      'anonymous'
    end
  end
  
  def name
    if PFUser.currentUser
      if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser)
        "Awesome Cabler"
      else
        PFUser.currentUser.objectForKey('name')
      end
    else
      "Awesome Cabler"
    end
  end
  
  def profile_status
    if @favorite_songs.count <= 1
      fav_suffix = "favorite song"
    else
      fav_suffix = "favorite songs"
    end
    
    if @bookmarked_events.count <= 1
      event_suffix = "event bookmarker"
    else
      event_suffix = "event bookmarkers"
    end
    
    "#{@favorite_songs.count} #{fav_suffix} / #{@bookmarked_events.count} #{event_suffix}"
  end
  
  def facebook_id
    if PFUser.currentUser
      PFUser.currentUser.objectForKey('facebookId')
    end
  end
  
  def profile_image_url(pic_width=64)
    if facebook_id
      "http://graph.facebook.com/#{facebook_id}/picture?width=#{pic_width}&height=#{pic_width}"
    end
  end
  
  def establish_favorites_ref    
    @favorites_ref  = @firebase_ref.childByAppendingPath "favorites/#{user_id}/songs"
    @favorites_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @favorite_songs = snapshot.value.clone
      else
        @favorite_songs = []
      end
      if App.profile_view_controller
        App.profile_view_controller.refresh_fav_table
        App.profile_view_controller.update_status
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def add_favorite_song(song)
    remove_favorite_song(song)
    @favorite_songs.insert(0, song)
    
    @favorites_ref.setValue @favorite_songs
    
    Robot.instance.send_like_event_with_song(song)
  end
  
  def remove_favorite_song(song)
    @favorite_songs.each_index do |index|
      favorite_song = @favorite_songs[index]
      if favorite_song[:video_id] == song[:video_id]
        @favorite_songs.delete_at(index)
      end
    end
    
    @favorites_ref.setValue @favorite_songs
    
    Robot.instance.send_unlike_event_with_song(song)
  end
  
  def has_favorited_song?(song)    
    @favorite_songs.each_index do |index|
      favorite_song = @favorite_songs[index]
      if favorite_song[:video_id] == song[:video_id]
        return true
      end
    end
    
    return false
  end
  
  def establish_bookmarked_events_ref    
    @bookmarked_events_ref = @firebase_ref.childByAppendingPath "events/#{user_id}/bookmarked"
    @bookmarked_events_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @bookmarked_events = snapshot.value.clone
      else
        @bookmarked_events = []
      end
      if App.profile_view_controller
        App.profile_view_controller.refresh_events_table
        App.profile_view_controller.update_status
      end
      if App.events_view_controller
        App.events_view_controller.refresh_bookmarked_table
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def bookmark_event(event)
    unbookmark_event event
    @bookmarked_events.insert(0, event)
    
    @bookmarked_events_ref.setValue @bookmarked_events
  end
  
  def unbookmark_event(event)
    @bookmarked_events.each_index do |index|
      bookmarked_event = @bookmarked_events[index]
      if bookmarked_event[:id] == event[:id]
        @bookmarked_events.delete_at(index)
      end
    end
    
    @bookmarked_events_ref.setValue @bookmarked_events
  end
  
  def has_bookmarked_event?(event)
    @bookmarked_events.each_index do |index|
      bookmarked_event = @bookmarked_events[index]
      if bookmarked_event[:id] == event[:id]
        return true
      end
    end
    
    return false
  end
  
  def set_private_channel_and_save
    unless PFUser.currentUser.nil?
      PFUser.currentUser.setObject "user_#{PFUser.currentUser.objectId}", forKey:CBUserPrivateChannelKey
      if PFUser.currentUser.isDirty
        PFUser.currentUser.saveInBackground
      end
    end
  end
  
  def fetch_recommended_events
    @recommended_events = [{
      :id => 1,
      :title => "The Von Trapps at The Chapel (February 28, 2015)", :subtitle => 'The Von Trapps', :source => 'songkick',
      :event_time => "February 28th, 2015 6:00PM - 10:00PM",
      :artist_name => 'The von Trapps',
      :bio => "The von Trapps is a musical group made up of Sofia, Melanie, Amanda and August von Trapp, descendants of the Trapp Family Singers.",
      :link => "http://www.songkick.com/festivals/944374/id/22927913-hillbilly-robot-an-urban-americana-music-event-2015",
      :image_url => 'http://userserve-ak.last.fm/serve/126/11997971.jpg',
      :large_image_url => 'http://userserve-ak.last.fm/serve/500/11997971.png'
    }, {
      :id => 2,
      :title => "Sean Hayes at The New Parish (February 20, 2015)", :subtitle => 'Sean Hayes', :source => 'songkick',
      :event_time => "February 20th, 2015 6:00PM - 10:00PM",
      :artist_name => 'Sean Hayes',
      :bio => "Hayes is a native of New York City, but was raised in North Carolina. He began playing traditional American and Irish music with a band called the Boys of Bluehill. He traveled the south, from the Black Mountain Music festival (LEAF Festival) in the Blue Ridge Mountains down to Charleston, South Carolina and eventually found his way to San Francisco, where he has lived since 1992.",
      :link => "http://www.songkick.com/festivals/944374/id/22927913-hillbilly-robot-an-urban-americana-music-event-2015",
      :image_url => 'http://userserve-ak.last.fm/serve/126/94602735.png',
      :large_image_url => 'http://userserve-ak.last.fm/serve/500/94602735.png'
    }, {
      :id => 3,
      :title => 'The Kinks at The Chapel (March 01, 2015)', :subtitle => 'The Kinks', :source => 'songkick',
      :event_time => "March 1st, 2015 6:00PM - 10:00PM",
      :artist_name => 'The Kinks',
      :bio => "The Kinks were an English rock band formed in Muswell Hill, North London, by brothers Dave Davies and Ray Davies with Pete Quaife in 1963.",
      :link => "http://www.songkick.com/festivals/944374/id/22927913-hillbilly-robot-an-urban-americana-music-event-2015",
      :image_url => 'http://userserve-ak.last.fm/serve/126/86692565.png',
      :large_image_url => 'http://userserve-ak.last.fm/serve/500/86692565.png'
    }]
  end
  
end