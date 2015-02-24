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
    fetch_auth_data
  end
  
  def is_logged_in?
    PFUser.currentUser != nil
  end
  
  def fetch_auth_data
    if is_logged_in?
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
    fetch_recommended_events
    fetch_bookmarked_events
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
    if is_logged_in?
      PFUser.currentUser.objectForKey('name')
    else
      "Awesome Cabler"
    end
  end
  
  def profile_status
    "12 favorite songs / 33 event bookmarkers"
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
      end
    end), withCancelBlock:(lambda do |error|
      NSLog("%@", error.description) 
    end)
  end
  
  def add_favorite_song(song)
    remove_favorite_song(song)
    @favorite_songs.insert(0, song)
    
    @favorites_ref.setValue @favorite_songs
  end
  
  def remove_favorite_song(song)
    @favorite_songs.each_index do |index|
      favorite_song = @favorite_songs[index]
      if favorite_song[:video_id] == song[:video_id]
        @favorite_songs.delete_at(index)
      end
    end
    
    @favorites_ref.setValue @favorite_songs
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
  
  def fetch_recommended_events
    @recommended_events = [{
      :title => "The Von Trapps at The Chapel (February 28, 2015)", :subtitle => 'The Von Trapps', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/11997971.jpg'
    }, {
      :title => 'Paula Harris at Club Fox (March 02, 2015)', :subtitle => 'Paula Harris', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/75018252.jpg'
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
  
  def connect_to_facebook
    FBSession.openActiveSessionWithReadPermissions ["public_profile"], allowLoginUI:true,
      completionHandler:(lambda do |session, state, error|
        if error
          NSLog("Facebook login failed. Error: %@", error)
        elsif state == FBSessionStateOpen
          accessToken = session.accessTokenData.accessToken;
          @firebase_ref.authWithOAuthProvider "facebook", token:accessToken,
            withCompletionBlock:(lambda do |error, auth_data|
              if (error)
                NSLog("Login failed. %@", error)
              else
                @auth_data = auth_data
                NSLog("Logged in! %@", auth_data)
                first_name = auth_data.providerData['cachedUserProfile']['first_name']
                last_name  = auth_data.providerData['cachedUserProfile']['last_name']
                new_user = {
                  "provider"   => auth_data.provider,
                  "email"      => auth_data.providerData["email"],
                  "first_name" => first_name,
                  "last_name"  => last_name
                }
                @firebase_ref.childByAppendingPath("users")
                             .childByAppendingPath(auth_data.uid).setValue(new_user)
                             
                #@firebase_ref.childByAppendingPath("users").childByAutoId
              end
            end)
        end
      end)
  end
  
  def monitor_authentication
    @firebase_ref.observeAuthEventWithBlock(lambda do |auth_data|
      if auth_data
        @auth_data = auth_data
      else
        NSLog "no user"
      end
    end)
  end
  
end