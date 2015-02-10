class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible
    
    @window.rootViewController = App.home_view_controller
    
    Parse.setApplicationId(PARSE_APP_ID, clientKey:PARSE_CLIENT_KEY)
    PFFacebookUtils.initializeFacebook

    true
  end
end
