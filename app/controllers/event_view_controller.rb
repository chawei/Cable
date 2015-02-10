class EventViewController < CBUIViewController
  include Style
  include EventTableViewDelegate
  
  def init_with_event_object(event_object)
    init
    
    self
  end
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    apply_rounded_corner
  end
  
  def viewDidLayoutSubviews
    #add_event_table_view
    add_action_bar_view
  end
  
  def add_event_table_view
    @event_table_view = UITableView.alloc.init
    @event_table_view.delegate   = self
    @event_table_view.dataSource = self
    view.addSubview @event_table_view
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
    
    @play_button = UIButton.buttonWithType UIButtonTypeCustom
    @play_button.frame = [[@action_bar_view.size.width-CBDefaultButtonWidth*2-CBDefaultMargin*2, CBDefaultMargin], 
      [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @play_button.setImage CBPlayIconImage, forState:UIControlStateNormal
    @play_button.addTarget self, action:"press_play_button", forControlEvents:UIControlEventTouchUpInside
    @action_bar_view.addSubview @play_button
    
    @bookmark_button = UIButton.buttonWithType UIButtonTypeCustom
    @bookmark_button.frame = [[@action_bar_view.size.width-CBDefaultButtonWidth-CBDefaultMargin, CBDefaultMargin], 
      [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @bookmark_button.setImage CBBookmarkIconImage, forState:UIControlStateNormal
    @bookmark_button.addTarget self, action:"press_bookmark_button", forControlEvents:UIControlEventTouchUpInside
    @action_bar_view.addSubview @bookmark_button
    
    view.addSubview @action_bar_view
  end
  
  def press_bookmark_button
    
  end
  
  def press_play_button
    
  end
  
  def press_close_button
    UIView.animateWithDuration 0.2, delay:0.0, options:UIViewAnimationOptionCurveEaseInOut, animations:(lambda do
        view.origin = [CBDefaultMargin, view.size.height]
        #view.alpha  = CBInactiveAlphaValue
      end), 
      completion:(lambda do |finished|
        self.view.removeFromSuperview
        self.removeFromParentViewController
      end)
  end
  
end