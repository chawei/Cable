class LoginViewController < CBUIViewController
  include Style
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.colorWithRed 60/255.0, green:60/255.0, blue:60/255.0, alpha:0.3
  end
  
  def viewDidLayoutSubviews
    add_alert_view
  end
  
  def add_alert_view
    margin = CBDefaultMargin
    @alert_view = UIView.alloc.initWithFrame [[margin, App.status_bar_height + margin], 
      [view.size.width - 2*margin, view.size.height - 2*margin - App.status_bar_height]]
    @alert_view.backgroundColor = UIColor.whiteColor
    apply_rounded_corner_on_view @alert_view
    
    view.addSubview @alert_view
    
    add_subviews
  end
  
  def add_subviews
    image_height = CBGuestImageHeight
    image_width  = CBGuestImageWidth
    image_view = UIImageView.alloc.initWithFrame [[(@alert_view.size.width-image_width)/2, 50], [image_width, image_height]]
    image_view.image = CBGuestImage
    
    message_label               = UILabel.alloc.initWithFrame [[0, 0], self.view.size]
    message_label.text          = "Login to Cable and\n start collecting your favorite songs!"
    message_label.textColor     = CBLightGrayColor
    message_label.numberOfLines = 0
    message_label.textAlignment = NSTextAlignmentCenter
    message_label.font = UIFont.fontWithName(CBRegularFontName, size:16.0)
    message_label.sizeToFit
    
    #origin_y = (@alert_view.size.height - image_view.size.height - 10 - message_label.size.height - 40)/2
    #image_view.origin   = [image_view.origin.x, origin_y]
    message_label.frame = [[(@alert_view.size.width-message_label.size.width)/2, image_view.origin.y+image_view.size.height+10],
      message_label.size]
      
    @alert_view.addSubview image_view
    @alert_view.addSubview message_label
      
    button_left_margin = 3*CBDefaultMargin
    button_width  = @alert_view.size.width - 2*button_left_margin
    button_height = CBDefaultButtonHeight #40
    font_size     = 16.0 #20.0
    button_margin = 8
    
    @fb_button = UIButton.buttonWithType UIButtonTypeCustom
    @fb_button.frame = [[button_left_margin, message_label.origin.y+message_label.size.height+2*CBDefaultMargin], 
      [button_width, button_height]]
    @fb_button.setTitle "Login with Facebook", forState:UIControlStateNormal
    @fb_button.titleLabel.setFont UIFont.fontWithName(CBRegularFontName, size:font_size)
    @fb_button.setTitleColor UIColor.whiteColor, forState:UIControlStateNormal
    @fb_button.backgroundColor    = UIColor.colorWithRed 59/255.0, green:89/255.0, blue:152/255.0, alpha:1.0
    @fb_button.layer.borderColor  = UIColor.whiteColor.CGColor
    @fb_button.layer.borderWidth  = 0.5
    @fb_button.layer.cornerRadius = CBRoundedCornerRadius
    @fb_button.addTarget self, action:"press_fb_login", forControlEvents:UIControlEventTouchUpInside
    @alert_view.addSubview @fb_button
    
    @twitter_button = UIButton.buttonWithType UIButtonTypeCustom
    @twitter_button.frame = [[button_left_margin, @fb_button.origin.y+@fb_button.size.height+button_margin], 
      [button_width, button_height]]
    @twitter_button.setTitle "Login with Twitter", forState:UIControlStateNormal
    @twitter_button.titleLabel.setFont UIFont.fontWithName(CBRegularFontName, size:font_size)
    @twitter_button.setTitleColor UIColor.whiteColor, forState:UIControlStateNormal
    @twitter_button.backgroundColor    = UIColor.colorWithRed 85/255.0, green:172/255.0, blue:238/255.0, alpha:1.0
    @twitter_button.layer.borderColor  = UIColor.whiteColor.CGColor
    @twitter_button.layer.borderWidth  = 0.5
    @twitter_button.layer.cornerRadius = CBRoundedCornerRadius
    @twitter_button.addTarget self, action:"press_twitter_login", forControlEvents:UIControlEventTouchUpInside
    @alert_view.addSubview @twitter_button
    
    @cancel_button = UIButton.buttonWithType UIButtonTypeCustom
    @cancel_button.frame = [[button_left_margin, @twitter_button.origin.y+@twitter_button.size.height+2*button_margin], 
      [button_width, button_height]]
    @cancel_button.setTitle "Later", forState:UIControlStateNormal
    @cancel_button.titleLabel.setFont UIFont.fontWithName(CBRegularFontName, size:font_size)
    #@cancel_button.setTitleColor UIColor.whiteColor, forState:UIControlStateNormal
    @cancel_button.setTitleColor CBYellowColor, forState:UIControlStateNormal
    #@cancel_button.backgroundColor    = CBLightGrayColor
    #@cancel_button.layer.borderColor  = UIColor.whiteColor.CGColor
    #@cancel_button.layer.borderWidth  = 0.5
    #@cancel_button.layer.cornerRadius = CBRoundedCornerRadius
    @cancel_button.addTarget self, action:"press_close_button", forControlEvents:UIControlEventTouchUpInside
    @alert_view.addSubview @cancel_button
  end
  
  def press_fb_login
    loading
    User.current.connect_to_facebook(lambda do 
      User.current.fetch_auth_data_and_establish_data_refs
      if App.profile_view_controller
        App.profile_view_controller.refresh_header_view
      end
      close_with_animation
      finish_loading
    end)
  end
  
  def press_twitter_login
    loading
    User.current.login_to_twitter(lambda do 
      User.current.fetch_auth_data_and_establish_data_refs
      if App.profile_view_controller
        App.profile_view_controller.refresh_header_view
      end
      close_with_animation
      finish_loading
    end)
  end
  
  def press_close_button
    close_with_animation
  end
  
  def close_with_animation
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        view.origin = [0, view.size.height]
      end), 
      completion:(lambda do |finished|
        close
      end)
  end
  
  def close
    self.view.removeFromSuperview
    self.removeFromParentViewController
  end
  
  def loading
    @loading_view = UIView.alloc.initWithFrame self.view.frame
    @loading_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.24
    activity_view = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleWhiteLarge
    activity_view.center = @loading_view.center
    activity_view.startAnimating
    @loading_view.addSubview activity_view
    @loading_view.layer.zPosition = 100
    
    self.view.addSubview @loading_view
  end
  
  def finish_loading
    @loading_view.removeFromSuperview
  end
  
end