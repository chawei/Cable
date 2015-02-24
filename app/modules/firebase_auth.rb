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
end