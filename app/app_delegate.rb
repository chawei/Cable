class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Parse.setApplicationId(PARSE_APP_ID, clientKey:PARSE_CLIENT_KEY)
    PFFacebookUtils.initializeFacebook
    PFTwitterUtils.initializeWithConsumerKey TWITTER_API_KEY, consumerSecret:TWITTER_API_SECRET
    
    BITHockeyManager.sharedHockeyManager.configureWithIdentifier HOCKEY_CABLE_APP_ID
    BITHockeyManager.sharedHockeyManager.startManager
    BITHockeyManager.sharedHockeyManager.authenticator.authenticateInstallation
    
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = App.home_view_controller
    @window.makeKeyAndVisible

    true
  end
  
  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    if url.host == "cabl.in" || url.host == "www.cabl.in"
      Robot.instance.send_open_url_request url
    else
      return FBAppCall.handleOpenURL url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session
    end
  end
  
  def applicationDidBecomeActive(application)
    FBAppCall.handleDidBecomeActiveWithSession PFFacebookUtils.session
    
    if App.home_view_controller
      App.home_view_controller.say_hello_when_app_became_active
    end
  end
 
  def applicationWillTerminate(application)
    PFFacebookUtils.session.close
  end
  
  def applicationWillEnterForeground(application)
    Player.instance.end_background_task
  end
  
  def applicationWillResignActive(application)
    if Player.instance.is_playing?      
      Player.instance.create_new_background_task
    end
  end
  
  def applicationDidEnterBackground(application)
    if Player.instance.should_continue_playing_in_background?
      Player.instance.play_in_background
    else
      Player.instance.pause_in_background
    end
  end
end
