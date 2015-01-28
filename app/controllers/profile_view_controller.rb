class ProfileViewController < CBUIViewController
  include Style
  include ProfileTableViewDelegate
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    add_profile_image_view
    add_name_label
    add_status_label
    add_setting_button
    add_segmented_control
    add_table_view
    
    apply_rounded_corner
    
    @objects = [{
      :title => 'House of Cards', :subtitle => 'Radiohead', :source => 'youtube',
      :image_url => 'http://www.creativereview.co.uk/images/uploads/2009/05/radiohead.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers', :source => 'spotify',
      :image_url => 'http://ecx.images-amazon.com/images/I/41jZQc6jSwL._SS280.jpg'
    }, {
      :title => 'House of Cards', :subtitle => 'Radiohead', :source => 'youtube',
      :image_url => 'http://www.creativereview.co.uk/images/uploads/2009/05/radiohead.jpg'
    }, {
      :title => 'Souls Like the Wheels', :subtitle => 'The Avett Brothers', :source => 'spotify',
      :image_url => 'http://ecx.images-amazon.com/images/I/41jZQc6jSwL._SS280.jpg'
    }]
  end
  
  def viewWillLayoutSubviews
    super
    
    card_width        = self.view.size.width
    button_width      = 32
    image_view_width  = 60
    image_view_height = 60
    @profile_image_view.frame = [[(card_width-image_view_width)/2, CBDefaultMargin], [image_view_width, image_view_height]]
    @name_label.frame = [[CBDefaultMargin, @profile_image_view.frame.origin.y+@profile_image_view.size.height+CBDefaultMargin],
      [card_width-CBDefaultMargin*2, 20]]
    @status_label.frame = [[CBDefaultMargin, @name_label.frame.origin.y+@name_label.size.height+5],
      [card_width-CBDefaultMargin*2, 15]]
    @setting_button.frame = [[card_width-CBDefaultMargin-button_width, CBDefaultMargin],
        [button_width, button_width]]
    @segmented_control.frame = [[CBDefaultMargin, @status_label.frame.origin.y+@status_label.size.height+CBDefaultMargin], 
        [view.size.width-CBDefaultMargin*2, 34]]
    table_origin_y = @segmented_control.frame.origin.y+@segmented_control.size.height+CBDefaultMargin
    @table_view.frame = [[0, table_origin_y], 
        [view.size.width, view.size.height-table_origin_y-CBRoundedCornerRadius]]
  end
  
  def add_profile_image_view
    @profile_image_view = UIImageView.alloc.initWithImage CBTestProfileImage
    view.addSubview @profile_image_view
  end
  
  def add_name_label
    @name_label = UILabel.alloc.init
    @name_label.numberOfLines = 1
    @name_label.textAlignment = NSTextAlignmentCenter
    @name_label.textColor     = UIColor.blackColor
    @name_label.setFont UIFont.fontWithName("OpenSans-Light", size:18.0)
    @name_label.text = "David Hsu"
    view.addSubview @name_label
  end
  
  def add_status_label
    @status_label = UILabel.alloc.init
    @status_label.numberOfLines = 1
    @status_label.textAlignment = NSTextAlignmentCenter
    @status_label.textColor     = UIColor.grayColor
    @status_label.setFont UIFont.fontWithName("OpenSans-Light", size:12.0)
    @status_label.text = "12 favorite songs / 12 event bookmarkers"
    view.addSubview @status_label
  end
  
  def add_setting_button
    @setting_button = UIButton.buttonWithType UIButtonTypeCustom
    @setting_button.setImage CBSettingIconImage, forState:UIControlStateNormal
    @setting_button.addTarget self, action:"press_setting_button", forControlEvents:UIControlEventTouchUpInside
    view.addSubview @setting_button
  end
  
  def add_segmented_control
    font       = UIFont.fontWithName("OpenSans", size:14.0)
    attributes = NSDictionary.dictionaryWithObject font, forKey:NSFontAttributeName
    tint_color = UIColor.colorWithRed 253/255.0, green:195/255.0, blue:0/255.0, alpha:1.0
    item_array = ["FAVORITES", "EVENTS"]
    @segmented_control = UISegmentedControl.alloc.initWithItems item_array
    @segmented_control.segmentedControlStyle = UISegmentedControlStylePlain
    @segmented_control.tintColor = tint_color
    @segmented_control.addTarget self, action:"segmented_control_changed", forControlEvents:UIControlEventValueChanged
    @segmented_control.selectedSegmentIndex = 0
    @segmented_control.setTitleTextAttributes attributes, forState:UIControlStateNormal
    view.addSubview @segmented_control
  end
  
  def add_table_view
    @table_view = UITableView.alloc.init
    @table_view.delegate   = self
    @table_view.dataSource = self
    view.addSubview @table_view
  end
  
  def segmented_control_changed
    
  end
  
  def press_setting_button
    
  end
  
  def toggle_display
    if view.isHidden
      view.alpha  = 0
      view.hidden = false
      UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
          view.alpha = 1
        end), 
        completion:nil
    else
      UIView.animateWithDuration 0.25, delay:0.0, options:UIViewAnimationOptionCurveLinear, animations:(lambda do
          view.alpha = 0
        end), 
        completion:(lambda do |finished|
          view.hidden = true
        end)
    end
  end
end