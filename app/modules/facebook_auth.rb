module FacebookAuth
  
  def connect_to_facebook(block=nil)
    NSLog "connect_to_facebook"
    permissions_array = CBFacebookPermissions
    PFFacebookUtils.logInWithPermissions(permissions_array, block:lambda do |user, error|
      NSLog "PFFacebookUtils.logInWithPermissions"
      if !user
        if !error
          #MixpanelClient.trackFBLoginEvent "User cancelled FB login"
        else
          #MixpanelClient.trackFBLoginEvent "User failed to sign up with FB: #{error.localizedDescription}"
          #MixpanelClient.trackFBLoginError "facebookLoginWithPermissionsWithBlock: #{error.localizedDescription}"
        end
      else 
        if user.isNew
          #MixpanelClient.trackFBLoginEvent "New user signed up with FB"
        else
          #MixpanelClient.trackFBLoginEvent "Existing user logged in through FB"
        end
      
        #if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser)
        load_fb_data
        #end
      end
    
      if block
        block.call
      end
    end)
  end
  
  def load_fb_data
    NSLog "load_fb_data"
    request = FBRequest.requestForMe
    request.startWithCompletionHandler(lambda do |connection, result, error|
      if !error
        facebook_request_did_load result
      else
        facebook_request_did_fail_with_error error
      end
    end)
  end
  
  def facebook_request_did_load(result)
    NSLog "facebook_request_did_load"
    facebook_id = result.objectForKey('id')
    if PFUser.currentUser.objectForKey('facebookId').nil? && facebook_id != nil
      PFUser.currentUser.setObject facebook_id, forKey:"facebookId"
    end
    
    field_names = ['gender', 'email', 'name', 'first_name', 'last_name', 'locale', 'timezone']
    field_names.each do |field_name|
      field_value = result.objectForKey(field_name)
      if PFUser.currentUser && field_value != nil
        PFUser.currentUser.setObject field_value, forKey:field_name
      end
    end
    
    set_private_channel_and_save
  end
  
  def facebook_request_did_fail_with_error(error)
    if error
      #MixpanelClient.trackFBLoginError "facebookRequestDidFailWithError: #{error.localizedDescription}"
    end
  end
end