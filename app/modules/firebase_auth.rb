module FirebaseAuth
  
  def user_id
    if @auth_data
      @auth_data.uid
    else
      'anonymous'
    end
  end
  
  def is_logged_in?
    @auth_data != nil && @auth_data.provider != 'anonymous'
  end
  
  def fetch_auth_data
    @auth_data = @firebase_ref.authData
    
    if @auth_data.nil?
      @firebase_ref.authAnonymouslyWithCompletionBlock(lambda do |error, authData|
        if error
          NSLog "Login failed."
        else
          NSLog "Login successfully as an anonymous."
          establish_data_refs
        end
      end)
    else
      establish_data_refs
    end
  end
  
  def connect_to_facebook_via_firebase
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