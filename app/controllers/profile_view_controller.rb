class ProfileViewController < CBUIViewController
  include Style
  include TableViewDelegate
  include ProfileTableViewDelegate
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    @user = User.current
    
    add_profile_image_view
    add_name_label
    add_status_label
    add_setting_button
    add_segmented_control
    add_table_views
    
    apply_rounded_corner
    
    @objects = fetch_song_objects
  end
  
  def viewWillLayoutSubviews
    super
    
    card_width        = self.view.size.width
    @profile_image_view.frame = [[(card_width-CBProfileImageWidth)/2, CBDefaultMargin], 
      [CBProfileImageWidth, CBProfileImageHeight]]
    @name_label.frame = [[CBDefaultMargin, @profile_image_view.frame.origin.y+@profile_image_view.size.height+CBDefaultMargin],
      [card_width-CBDefaultMargin*2, 20]]
    @status_label.frame = [[CBDefaultMargin, @name_label.frame.origin.y+@name_label.size.height+5],
      [card_width-CBDefaultMargin*2, 16]]
    @setting_button.frame = [[card_width-CBDefaultMargin-CBDefaultButtonWidth, CBDefaultMargin],
      [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @segmented_control.frame = [[CBDefaultMargin, @status_label.frame.origin.y+@status_label.size.height+CBDefaultMargin], 
      [view.size.width-CBDefaultMargin*2, 34]]
      
    table_origin_y = @segmented_control.frame.origin.y+@segmented_control.size.height+CBDefaultMargin
    @fav_table_view.frame = [[0, table_origin_y], 
      [view.size.width, view.size.height-table_origin_y-CBRoundedCornerRadius]]
    @event_table_view.frame = [[0, table_origin_y], 
      [view.size.width, view.size.height-table_origin_y-CBRoundedCornerRadius]]
  end
  
  def add_profile_image_view
    @profile_image_view = UIImageView.alloc.initWithImage CBDefaultProfileImage
    @profile_image_view.setImageWithURL NSURL.URLWithString(User.current.profile_image_url(CBProfileImageWidth*2)),
                   placeholderImage:CBDefaultProfileImage
    view.addSubview @profile_image_view
  end
  
  def add_name_label
    @name_label = UILabel.alloc.init
    @name_label.numberOfLines = 1
    @name_label.textAlignment = NSTextAlignmentCenter
    @name_label.textColor     = UIColor.blackColor
    @name_label.setFont UIFont.fontWithName(CBRegularFontName, size:18.0)
    @name_label.text = @user.name
    view.addSubview @name_label
  end
  
  def add_status_label
    @status_label = UILabel.alloc.init
    @status_label.numberOfLines = 1
    @status_label.textAlignment = NSTextAlignmentCenter
    @status_label.textColor     = UIColor.grayColor
    @status_label.setFont UIFont.fontWithName(CBLightFontName, size:12.0)
    @status_label.text = @user.profile_status
    view.addSubview @status_label
  end
  
  def add_setting_button
    @setting_button = UIButton.buttonWithType UIButtonTypeCustom
    @setting_button.setImage CBSettingIconImage, forState:UIControlStateNormal
    @setting_button.addTarget self, action:"press_setting_button", forControlEvents:UIControlEventTouchUpInside
    view.addSubview @setting_button
  end
  
  def add_segmented_control
    font       = UIFont.fontWithName(CBRegularFontName, size:14.0)
    attributes = NSDictionary.dictionaryWithObject font, forKey:NSFontAttributeName
    tint_color = UIColor.colorWithRed 253/255.0, green:195/255.0, blue:0/255.0, alpha:1.0
    item_array = ["FAVORITES", "EVENTS"]
    @segmented_control = UISegmentedControl.alloc.initWithItems item_array
    @segmented_control.segmentedControlStyle = UISegmentedControlStylePlain
    @segmented_control.tintColor = tint_color
    @segmented_control.addTarget self, action:"segmented_control_changed:", forControlEvents:UIControlEventValueChanged
    @segmented_control.selectedSegmentIndex = 0
    @segmented_control.setTitleTextAttributes attributes, forState:UIControlStateNormal
    view.addSubview @segmented_control
  end
  
  def add_table_views
    @fav_table_view = UITableView.alloc.init
    @fav_table_view.delegate   = self
    @fav_table_view.dataSource = self
    view.addSubview @fav_table_view
    
    @event_table_view = UITableView.alloc.init
    @event_table_view.delegate   = self
    @event_table_view.dataSource = self
    @event_table_view.hidden = true
    view.addSubview @event_table_view
  end
  
  def fetch_song_objects
    @user.favorite_songs
  end
  
  def fetch_event_objects
    @user.bookmarked_events
  end
  
  def update_status
    if @status_label
      @status_label.text = @user.profile_status
    end
  end
  
  def refresh_fav_table
    @objects = fetch_song_objects
    @fav_table_view.reloadData
  end
  
  def refresh_events_table
    @objects = fetch_event_objects
    @event_table_view.reloadData
  end
  
  def segmented_control_changed(sender)
    selected_segment = sender.selectedSegmentIndex
    case selected_segment
    when 0
      @objects = fetch_song_objects
      @fav_table_view.reloadData
      @fav_table_view.hidden   = false
      @event_table_view.hidden = true
    when 1
      @objects = fetch_event_objects
      @event_table_view.reloadData
      @fav_table_view.hidden   = true
      @event_table_view.hidden = false
    end
  end
  
  def press_setting_button
    @settings_view_controller = SettingsViewController.alloc.init
    @settings_view_controller.view.frame = [[0, view.size.height], 
      [view.size.width, view.size.height]]
    #@@settings_view_controller.view.alpha  = CBInactiveAlphaValue

    self.addChildViewController @settings_view_controller
    self.view.addSubview @settings_view_controller.view
    @settings_view_controller.didMoveToParentViewController self
  
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        @settings_view_controller.view.origin = [0, 0]
        @settings_view_controller.view.alpha  = CBActiveAlphaValue
      end), 
      completion:(lambda do |finished|
      end)
  end
  
  def toggle_display
    if view.isHidden
      show
    else
      hide
    end
  end
  
  def show
    view.alpha  = 0
    view.hidden = false
    UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
        view.alpha = 1
      end), 
      completion:nil
  end
  
  def hide
    UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
        view.alpha = 0
      end), 
      completion:(lambda do |finished|
        view.hidden = true
      end)
  end
end