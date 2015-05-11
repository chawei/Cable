class User
  include FacebookAuth
  include TwitterAuth
  include Validation
  
  @@current_user = nil
  
  attr_accessor :favorite_songs
  attr_accessor :bookmarked_events
  attr_accessor :nearby_events
  attr_accessor :recommended_events
  attr_accessor :session
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
    @nearby_events      ||= []
    @session            ||= Session.new
    
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
    establish_nearby_events_ref
    establish_recommended_events_ref
    fetch_location_and_ask_for_events
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
    
    #"#{@favorite_songs.count} #{fav_suffix} / #{@bookmarked_events.count} #{event_suffix}"
    "#{@favorite_songs.count} #{fav_suffix}"
  end
  
  def facebook_id
    if PFUser.currentUser
      PFUser.currentUser.objectForKey('facebookId')
    end
  end
  
  def twitter_id
    if PFUser.currentUser
      PFUser.currentUser.objectForKey('twitterId')
    end
  end
  
  def profile_image_url(pic_width=64)
    if facebook_id
      "http://graph.facebook.com/#{facebook_id}/picture?width=#{pic_width}&height=#{pic_width}"
    elsif twitter_id
      PFUser.currentUser.objectForKey('twitterProfileImageUrl')
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
    @favorite_songs.insert(0, song)
    
    save_favorites @favorite_songs
    Robot.instance.send_like_event_with_song(song)
  end
  
  def remove_favorite_song(song)
    @favorite_songs.each_index do |index|
      favorite_song = @favorite_songs[index]
      if favorite_song[:video_id] == song[:video_id]
        @favorite_songs.delete_at(index)
      end
    end
    
    save_favorites @favorite_songs
    Robot.instance.send_unlike_event_with_song(song)
  end
  
  def save_favorites(favorites)
    favorites = validate_objects favorites
    @favorites_ref.setValue favorites
  end
  
  def has_favorited_song?(song)
    is_favorited = false
    @favorite_songs.each_index do |index|
      if favorite_song = @favorite_songs[index]
        if song[:source] == 'youtube'
          if favorite_song[:video_id] && favorite_song[:video_id] == song[:video_id]
            is_favorited = true
          end
        elsif song[:source] == 'spotify'
          if favorite_song[:spotify_id] && favorite_song[:spotify_id] == song[:spotify_id]
            is_favorited = true
          end
        end
      end
    end
    
    return is_favorited
  end
  
  def establish_bookmarked_events_ref    
    @bookmarked_events_ref = @firebase_ref.childByAppendingPath "events/#{user_id}/bookmarked"
    @bookmarked_events_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @bookmarked_events = validate_objects snapshot.value.clone
      else
        @bookmarked_events = []
      end
      if App.profile_view_controller
        App.profile_view_controller.refresh_events_table
        App.profile_view_controller.update_status
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def bookmark_event(event)
    unbookmark_event event
    @bookmarked_events.insert(0, event)
    
    save_bookmark_events @bookmarked_events
  end
  
  def unbookmark_event(event)
    @bookmarked_events.each_index do |index|
      bookmarked_event = @bookmarked_events[index]
      if bookmarked_event[:id] == event[:id]
        @bookmarked_events.delete_at(index)
      end
    end
    
    save_bookmark_events @bookmarked_events
  end
  
  def save_bookmark_events(events)
    events = validate_objects events
    @bookmarked_events_ref.setValue events
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
  
  def establish_nearby_events_ref    
    @nearby_events_ref = @firebase_ref.childByAppendingPath "nearby_events/#{user_id}/objects"
    @nearby_events_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @nearby_events = validate_objects snapshot.value.clone
      else
        @nearby_events = []
      end
      
      if App.events_view_controller
        App.events_view_controller.refresh_nearby_table
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def establish_recommended_events_ref    
    @recommended_events_ref = @firebase_ref.childByAppendingPath "recommended_events/#{user_id}/objects"
    @recommended_events_ref.observeEventType FEventTypeValue, withBlock:(lambda do |snapshot| 
      if snapshot.value
        @recommended_events = validate_objects snapshot.value.clone
      else
        @recommended_events = []
      end
      
      if App.events_view_controller
        App.events_view_controller.refresh_recommended_table
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def fetch_location_and_ask_for_events
    manager = AFHTTPRequestOperationManager.manager
    url_str = "http://api.songkick.com/api/3.0/events.json?location=clientip&apikey=TtVDmSAI62x8Ymbd"
    manager.GET url_str, parameters:nil, success:(lambda { |operation, response|
      client_location = response['resultsPage']['clientLocation']
      if client_location
        location = {
          :ip  => client_location['ip'],
          :lat => client_location['lat'],
          :lng => client_location['lng']
        }
        Robot.instance.send_update_events_request_with_location_info(location)
      end
    }).weak!, failure:(lambda { |operation, error|
      NSLog("Error: %@", error)
    }).weak!
  end
  
  def fetch_recommended_events
    manager   = AFHTTPRequestOperationManager.manager
    urlString = "http://api.songkick.com/api/3.0/events.json?location=clientip&apikey=TtVDmSAI62x8Ymbd"
    manager.GET urlString, parameters:nil, success:(lambda { |operation, response|
      events  = []
      results = response['resultsPage']['results']
      if results
        raw_events = results['event']
        raw_events.each do |raw_event|
          artist_name = ''
          image_url   = nil
          if raw_event['performance'].length > 0
            artist_name = raw_event['performance'][0]['displayName']
            artist_id   = raw_event['performance'][0]['artist']['id']
            image_url   = "http://assets.sk-static.com/images/media/profile_images/artists/#{artist_id}/card_avatar"
          end
          event_time = "#{raw_event['start']['date']} #{raw_event['start']['time']}"
          event = {
            :id          => "songkick:#{raw_event['id']}",
            :title       => raw_event['displayName'], 
            :subtitle    => artist_name, :source => 'songkick',
            :event_time  => event_time,
            :artist_name => artist_name,
            :bio         => "",
            :link        => raw_event['uri'],
            :image_url   => image_url,
            :large_image_url => image_url
          }
          events << event
        end
      end
      
      @recommended_events_ref.setValue events
    }).weak!, failure:(lambda { |operation, error|
      NSLog("Error: %@", error)
      }).weak!
  end
  
end