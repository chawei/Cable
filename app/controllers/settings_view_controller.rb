class SettingsViewController < CBUIViewController
  include Style
  include SettingTableViewDelegate
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    apply_rounded_corner
  end
  
  def viewDidLayoutSubviews
    add_title_view
    add_action_bar_view
    add_settings_table_view
  end
  
  def add_title_view
    @title_view = UIView.alloc.initWithFrame [
      [0, 0],
      [view.size.width, CBDefaultButtonHeight+CBDefaultMargin*2]]
      
    bottom_border = CALayer.layer
    bottom_border.frame = CGRectMake(0.0, @title_view.size.height, @title_view.size.width, 2.0)
    bottom_border.backgroundColor = UIColor.colorWithRed(200/255.0, green:200/255.0, blue:200/255.0, alpha:0.24).CGColor
    @title_view.layer.addSublayer bottom_border
    @title_view.layer.zPosition = 100
    
    @title_label = UILabel.alloc.initWithFrame [[0, 0], @title_view.size]
    @title_label.numberOfLines = 1
    @title_label.textAlignment = NSTextAlignmentCenter
    @title_label.textColor     = UIColor.blackColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:18.0)
    @title_label.text = "Settings"
    
    @title_view.addSubview @title_label
    
    view.addSubview @title_view
  end
  
  def add_action_bar_view
    @action_bar_view = UIView.alloc.initWithFrame [
      [0, view.size.height-CBDefaultButtonHeight-CBDefaultMargin*2],
      [view.size.width, CBDefaultButtonHeight+CBDefaultMargin*2]]
      
    top_border = CALayer.layer
    top_border.frame = CGRectMake(0.0, 0.0, @action_bar_view.frame.size.width, 2.0)
    top_border.backgroundColor = UIColor.colorWithRed(200/255.0, green:200/255.0, blue:200/255.0, alpha:0.24).CGColor
    @action_bar_view.layer.addSublayer top_border
    
    @close_button = UIButton.buttonWithType UIButtonTypeCustom
    @close_button.frame = [[CBDefaultMargin, CBDefaultMargin], [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @close_button.setImage CBCloseIconImage, forState:UIControlStateNormal
    @close_button.addTarget self, action:"press_close_button", forControlEvents:UIControlEventTouchUpInside
    @action_bar_view.addSubview @close_button
    
    view.addSubview @action_bar_view
  end
  
  def add_settings_table_view
    @setting_table_view = UITableView.alloc.initWithFrame [[0, @title_label.size.height],
      [view.size.width, view.size.height-@title_label.size.height-@action_bar_view.size.height]], style:UITableViewStyleGrouped
    @setting_table_view.delegate   = self
    @setting_table_view.dataSource = self
    view.addSubview @setting_table_view
  end
  
  def press_close_button
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        view.origin = [0, view.size.height]
        #view.alpha  = CBInactiveAlphaValue
      end), 
      completion:(lambda do |finished|
        close
      end)
  end
  
  def close
    self.view.removeFromSuperview
    self.removeFromParentViewController
  end
  
end