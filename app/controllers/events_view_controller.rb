class EventsViewController < CBUIViewController
  include Style
  include EventsTableViewDelegate
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    add_segmented_control
    add_table_views
    
    apply_rounded_corner
    
    @objects = fetch_recommended_objects
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
  
  def fetch_recommended_objects
    [{
      :title => 'Sunny Afternoon', :subtitle => 'January 28, 2015', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/86692565.png'
    }, {
      :title => "The Von Trapps at The Chapel (January 28, 2015)", 
      :subtitle => 'The Von Trapps / January 28, 2015', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/11997971.jpg'
    }, {
      :title => 'The View from the Afternoon', :subtitle => 'Arctic Monkeys / January 30, 2015', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/32760011.png'
    }, {
      :title => 'Paula Harris at Club Fox (January 28, 2015)', :subtitle => 'Paula Harris', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/75018252.jpg'
    }]
  end
  
  def fetch_bookmarked_objects
    [{
      :title => "The Von Trapps at The Chapel (January 28, 2015)", :subtitle => 'The Von Trapps', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/11997971.jpg'
    }, {
      :title => 'The View from the Afternoon', :subtitle => 'Arctic Monkeys', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/32760011.png'
    }, {
      :title => 'Paula Harris at Club Fox (January 28, 2015)', :subtitle => 'Paula Harris', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/75018252.jpg'
    }, {
      :title => 'Sunny Afternoon', :subtitle => 'The Kinks', :source => 'songkick',
      :image_url => 'http://userserve-ak.last.fm/serve/126/86692565.png'
    }]
  end
  
  def segmented_control_changed(sender)
    selected_segment = sender.selectedSegmentIndex
    case selected_segment
    when 0
      @objects = fetch_recommended_objects
      @recommended_table_view.reloadData
      @recommended_table_view.hidden   = false
      @bookmarked_table_view.hidden = true
    when 1
      @objects = fetch_bookmarked_objects
      @bookmarked_table_view.reloadData
      @recommended_table_view.hidden   = true
      @bookmarked_table_view.hidden = false
    end
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