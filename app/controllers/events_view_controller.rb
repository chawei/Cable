class EventsViewController < CBUIViewController
  include Style
  include TableViewDelegate
  include EventsTableViewDelegate
  include ViewAnimation
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    add_segmented_control
    add_table_views
    
    apply_rounded_corner
    
    add_observers
  end
  
  def viewWillLayoutSubviews
    super
    
    card_width        = self.view.size.width
    @segmented_control.frame = [[CBDefaultMargin, CBDefaultMargin], 
      [view.size.width-CBDefaultMargin*2, 34]]
      
    table_origin_y = @segmented_control.frame.origin.y+@segmented_control.size.height+CBDefaultMargin
    @recommended_table_view.frame = [[0, table_origin_y], 
      [view.size.width, view.size.height-table_origin_y-CBRoundedCornerRadius]]
    @bookmarked_table_view.frame = [[0, table_origin_y], 
      [view.size.width, view.size.height-table_origin_y-CBRoundedCornerRadius]]
  end
  
  def add_segmented_control
    font       = UIFont.fontWithName(CBRegularFontName, size:14.0)
    attributes = NSDictionary.dictionaryWithObject font, forKey:NSFontAttributeName
    tint_color = UIColor.colorWithRed 253/255.0, green:195/255.0, blue:0/255.0, alpha:1.0
    item_array = ["RECOMMENDED", "BOOKMARKED"]
    @segmented_control = UISegmentedControl.alloc.initWithItems item_array
    @segmented_control.segmentedControlStyle = UISegmentedControlStylePlain
    @segmented_control.tintColor = tint_color
    @segmented_control.addTarget self, action:"segmented_control_changed:", forControlEvents:UIControlEventValueChanged
    @segmented_control.selectedSegmentIndex = 0
    @segmented_control.setTitleTextAttributes attributes, forState:UIControlStateNormal
    view.addSubview @segmented_control
  end
  
  def add_table_views
    @recommended_table_view = UITableView.alloc.init
    @recommended_table_view.delegate   = self
    @recommended_table_view.dataSource = self
    view.addSubview @recommended_table_view
    
    @bookmarked_table_view = UITableView.alloc.init
    @bookmarked_table_view.delegate   = self
    @bookmarked_table_view.dataSource = self
    @bookmarked_table_view.hidden = true
    view.addSubview @bookmarked_table_view
  end
  
  def add_observers
    
  end
  
  def recommended_objects
    User.current.recommended_events
  end
  
  def bookmarked_objects
    User.current.bookmarked_events
  end
  
  def segmented_control_changed(sender)
    selected_segment = sender.selectedSegmentIndex
    case selected_segment
    when 0
      @recommended_table_view.reloadData
      @recommended_table_view.hidden   = false
      @bookmarked_table_view.hidden = true
    when 1
      @bookmarked_table_view.reloadData
      @recommended_table_view.hidden   = true
      @bookmarked_table_view.hidden = false
    end
  end
  
  def refresh_recommended_table
    @recommended_table_view.reloadData
  end
  
  def refresh_bookmarked_table
    @bookmarked_table_view.reloadData
  end
  
  def toggle_display
    if view.isHidden
      show
    else
      hide
    end
  end
  
  def show
    show_view view
  end
  
  def hide
    hide_view view
  end
end