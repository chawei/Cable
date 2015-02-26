class EventViewController < CBUIViewController
  include Style
  include TableViewDelegate
  include EventTableViewDelegate
  
  def init_with_event_object(event_object)
    convert_event_object_to_data event_object
    
    init
    
    self
  end
  
  def event_object
    @event_object
  end
  
  def convert_event_object_to_data(event_object)
    @event_object = event_object
    @event_data = [
      { :title => "Event time", :detail => event_object[:event_time] },
      { :title => "Line up", :detail => event_object[:artist_name] },
      { :title => "Biographies", :detail => event_object[:bio] },
      { :title => "Official website", :detail => event_object[:link] }
    ]
  end
  
  def viewDidLoad
    super
    
    view.backgroundColor = UIColor.whiteColor
    
    apply_rounded_corner
  end
  
  def viewDidLayoutSubviews
    add_action_bar_view
    add_event_table_view
    
    update_bookmark_button
  end
  
  def add_event_table_view
    @event_table_view = UITableView.alloc.initWithFrame [[0, 0], 
      [view.size.width, view.size.height-@action_bar_view.size.height]]
    @event_table_view.delegate   = self
    @event_table_view.dataSource = self
    view.addSubview @event_table_view
    
    add_event_header_view
  end
  
  def add_event_header_view
    table_header_view = UIView.alloc.init
    
    title_label = UILabel.alloc.initWithFrame [[CBDefaultMargin, CBDefaultMargin], [view.size.width-CBDefaultMargin*2, 60]]
    title_label.numberOfLines = 0
    title_label.textAlignment = NSTextAlignmentLeft
    title_label.textColor     = UIColor.blackColor
    title_label.setFont UIFont.fontWithName(CBRegularFontName, size:20.0)
    title_label.text = @event_object[:title]
    title_label.setVerticalAlignmentTopWithHeight(60)
    #title_label.layer.backgroundColor = UIColor.colorWithRed(0.0, green:0.0, blue:0.0, alpha:0.2).CGColor
    
    event_image_view = UIImageView.alloc.initWithFrame [[0, title_label.size.height+CBDefaultMargin*2], 
      [view.size.width, 200]]
    event_image_view.contentMode = UIViewContentModeScaleAspectFit
    event_image_view.layer.backgroundColor = UIColor.colorWithRed(0.0, green:0.0, blue:0.0, alpha:1.0).CGColor
    image_url = NSURL.URLWithString @event_object[:large_image_url]
    SDWebImageDownloader.sharedDownloader.downloadImageWithURL image_url,
                                           options:0,
                                          progress:(lambda do |receivedSize, expectedSize|
                                          end),
                                         completed:(lambda do |image, data, error, finished|
                                           unless image && finished
                                             image = CBTransparentImage
                                           end
                                           #height = image.size.width/view.size.width*200
                                           #
                                           #top_margin = (image.size.height - height)/2.0
                                           #top_margin = 0 if top_margin < 0
                                           #
                                           #
                                           #crop_region   = CGRectMake(0, top_margin, image.size.width, height)
                                           #sub_image     = CGImageCreateWithImageInRect(image.CGImage, crop_region)
                                           #cropped_image = UIImage.imageWithCGImage sub_image
                                           #event_image_view.image = cropped_image
                                           
                                           event_image_view.image = image
                                         end)
    
    table_header_view.frame = [[0, 0], 
      [view.size.width, CBDefaultMargin+title_label.size.height+CBDefaultMargin+event_image_view.size.height]]
    table_header_view.addSubview title_label
    table_header_view.addSubview event_image_view
    @event_table_view.tableHeaderView = table_header_view
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
    
    if event_object && event_object[:artist_name]
      @play_button = UIButton.buttonWithType UIButtonTypeCustom
      @play_button.frame = [[@action_bar_view.size.width-CBDefaultButtonWidth*2-CBDefaultMargin*2, CBDefaultMargin], 
        [CBDefaultButtonWidth, CBDefaultButtonHeight]]
      @play_button.setImage CBPlayIconImage, forState:UIControlStateNormal
      @play_button.addTarget self, action:"press_play_button", forControlEvents:UIControlEventTouchUpInside
      @action_bar_view.addSubview @play_button
    end
    
    @bookmark_button = UIButton.buttonWithType UIButtonTypeCustom
    @bookmark_button.frame = [[@action_bar_view.size.width-CBDefaultButtonWidth-CBDefaultMargin, CBDefaultMargin], 
      [CBDefaultButtonWidth, CBDefaultButtonHeight]]
    @bookmark_button.setImage CBBookmarkIconImage, forState:UIControlStateNormal
    @bookmark_button.addTarget self, action:"press_bookmark_button", forControlEvents:UIControlEventTouchUpInside
    @action_bar_view.addSubview @bookmark_button
    
    view.addSubview @action_bar_view
  end
  
  def update_bookmark_button
    if event_object
      if User.current.has_bookmarked_event? event_object
        @bookmark_button.setImage CBBookmarkedIconImage, forState:UIControlStateNormal
      else
        @bookmark_button.setImage CBBookmarkIconImage, forState:UIControlStateNormal
      end
    end
  end
  
  def press_bookmark_button
    current_state_image = @bookmark_button.imageForState UIControlStateNormal
    if current_state_image == CBBookmarkIconImage
      if event_object
        @bookmark_button.setImage CBBookmarkedIconImage, forState:UIControlStateNormal
        User.current.bookmark_event event_object
      end
    else
      if event_object
        @bookmark_button.setImage CBBookmarkIconImage, forState:UIControlStateNormal
        User.current.unbookmark_event event_object
      end
    end
  end
  
  def press_play_button
    if event_object && event_object[:artist_name]
      request = { :message => event_object[:artist_name], :mode => 'artist_name', :user_id => User.current.user_id }
      Robot.instance.listen request
      
      press_close_button
      App.home_view_controller.tap_background
    end
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