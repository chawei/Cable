class MessageViewCell < UICollectionViewCell
  include Style
  
  def initWithFrame(frame)
    super frame
    
    @direction = 'left'
    
    @profile_image_view = UIImageView.alloc.initWithImage CBTestProfileImage
    @profile_image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [CBMessageProfileImageWidth, CBMessageProfileImageHeight]]
    apply_rounded_corner_on_view @profile_image_view
    
    @message_container = UIView.alloc.init
    @message_container.backgroundColor = UIColor.whiteColor
    
    @message_label_constraint_size = [self.size.width-CBMessagePadding*3-CBMessageTimeLabelWidth-CBMessageProfileImageWidth, 400]
    @message_label = UILabel.alloc.initWithFrame [[CBMessageProfileImageWidth, CBMessagePadding], 
      @message_label_constraint_size]
    @message_label.numberOfLines = 0
    @message_label.textColor = UIColor.blackColor
    @message_label.setFont UIFont.fontWithName(CBRegularFontName, size:14.0)
    @message_label.text = "Hello"
    @message_container.addSubview @message_label
    
    @time_label = UILabel.alloc.initWithFrame [[0, 0], [CBMessageTimeLabelWidth, CBMessageTimeLabelHeight]]
    @time_label.numberOfLines = 1
    @time_label.textColor = UIColor.whiteColor
    @time_label.setFont UIFont.fontWithName(CBRegularFontName, size:12.0)
    @time_label.text = "now"
    
    self.contentView.addSubview @time_label
    self.contentView.addSubview @message_container
    self.contentView.addSubview @profile_image_view
    
    self
  end
  
  def get_height_of_message_object(message_object)
    #message_object = message_object
    @message_label.text = message_object[:text]
    @message_label.setVerticalAlignmentTopWithConstraintSize @message_label_constraint_size
    
    @message_label.size.height+CBMessagePadding*2+CBMessagePadding
  end
  
  def message_object=(message_object)
    @message_label.text = message_object[:text]
    @message_label.setVerticalAlignmentTopWithConstraintSize @message_label_constraint_size
    
    @direction       = message_object[:direction]
    @time_label.text = message_object[:time_text]
    
    update_view
  end
    
  def update_view
    message_container_width = @message_label.size.width+CBMessagePadding*2+CBMessageProfileImageWidth
    if @direction == 'left'
      @message_container.frame = [[CBMessagePadding, 0], 
        [message_container_width, @message_label.size.height+CBMessagePadding*2]]
        
      @message_label.origin = [CBMessageProfileImageWidth, CBMessagePadding]
      @time_label.origin    = [@message_container.origin.x+@message_container.size.width+5, 
        @message_container.size.height-CBMessageTimeLabelHeight]
    else
      @message_container.frame = [[self.contentView.size.width-CBMessagePadding-message_container_width, 0], 
        [message_container_width, @message_label.size.height+CBMessagePadding*2]]
        
      @message_label.origin = [CBMessagePadding, CBMessagePadding]
      @time_label.origin    = [@message_container.origin.x-5-@time_label.size.width, 
        @message_container.size.height-CBMessageTimeLabelHeight]
    end
    
    apply_rounded_corner_on_view @message_container
    self.contentView.frame = [self.contentView.origin, [self.contentView.size.width, @message_container.size.height+CBMessagePadding]]
    
    update_profile_image_view
  end
  
  def update_profile_image_view
    if @direction == 'left'
      @profile_image_view.origin = [0, self.contentView.size.height-CBMessageProfileImageHeight]
    else
      @profile_image_view.origin = [self.contentView.size.width-CBMessageProfileImageWidth, self.contentView.size.height-CBMessageProfileImageHeight]
    end
  end
end