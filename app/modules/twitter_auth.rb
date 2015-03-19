module TwitterAuth
  
  def login_to_twitter(block=nil)
    PFTwitterUtils.logInWithBlock(lambda do |user, error|
      if !user
        NSLog "Uh oh. The user cancelled the Twitter login."
      else
        if user.isNew
          NSLog "User signed up and logged in with Twitter!"
        else
          NSLog "User logged in with Twitter!"
        end
        load_twitter_data(block)
      end
    end)
  end
  
  def load_twitter_data(block=nil)
    twitter_id          = PFTwitterUtils.twitter.userId
    twitter_screen_name = PFTwitterUtils.twitter.screenName
        
    url_str = "https://api.twitter.com/1.1/users/show.json?"
    if twitter_id
      url_str = url_str.stringByAppendingString NSString.stringWithFormat("user_id=%@", twitter_id)
    elsif twitter_screen_name
      url_str = url_str.stringByAppendingString NSString.stringWithFormat("screen_name=%@", twitter_screen_name)
    else
      NSLog "There are no credentials for Twitter login. Something went really wrong !"
      return
    end
    
    verify_url = NSURL.URLWithString url_str
    request    = NSMutableURLRequest.requestWithURL verify_url
    queue      = NSOperationQueue.alloc.init
    operation  = NSOperation.alloc.init
    operation.setQueuePriority NSOperationQueuePriorityVeryHigh
    queue.addOperation operation
    
    PFTwitterUtils.twitter.signRequest request
    NSURLConnection.sendAsynchronousRequest request, queue:queue, completionHandler:(lambda do |response, data, error|
      if error.nil?
        result = NSJSONSerialization.JSONObjectWithData data, options:NSJSONReadingAllowFragments, error:nil
        save_twitter_user_data result
        
        if block
          gcdq = Dispatch::Queue.concurrent(:high)
          gcdq.async do
            Dispatch::Queue.main.sync do
              block.call
            end
          end
        end
      end
    end)
  end
  
  def save_twitter_user_data(user_data)
    twitter_id = PFTwitterUtils.twitter.userId
    if PFUser.currentUser.objectForKey('twitterId').nil? && twitter_id != nil
      PFUser.currentUser.setObject twitter_id, forKey:"twitterId"
    end
    
    if PFUser.currentUser
      PFUser.currentUser.setObject user_data['screen_name'], forKey:'twitterScreenName'
      if user_data['name']
        PFUser.currentUser.setObject user_data['name'], forKey:'name'
      end
      if user_data['profile_image_url']
        profile_image_url = user_data['profile_image_url'].gsub("_normal", "")
        PFUser.currentUser.setObject profile_image_url, forKey:'twitterProfileImageUrl'
      end
    end
    
    set_private_channel_and_save
  end
  
end
