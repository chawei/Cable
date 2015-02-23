class MessageViewCell < UICollectionViewCell
  include Style
  
  def initWithFrame(frame)
    super frame
    
    @direction = 'left'
    
    @profile_image_view = UIImageView.alloc.initWithImage CBTransparentImage
    @profile_image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [CBMessageProfileImageWidth, CBMessageProfileImageHeight]]
    apply_rounded_corner_on_view @profile_image_view
    
    @message_container = UIView.alloc.init
    @message_container.backgroundColor = UIColor.whiteColor
    
    @message_label_constraint_size = [self.size.width-CBMessagePadding*3-CBMessageTimeLabelWidth-CBMessageProfileImageWidth, 400]
    @message_label = UILabel.alloc.initWithFrame [[CBMessageProfileImageWidth, CBMessagePadding], 
      @message_label_constraint_size]
    @message_label.numberOfLines = 0
    @message_label.textColor = CBBlackColor
    @message_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    @message_label.text = "Hello"
    @message_container.addSubview @message_label
    
    @time_label = UILabel.alloc.initWithFrame [[0, 0], [CBMessageTimeLabelWidth, CBMessageTimeLabelHeight]]
    @time_label.numberOfLines = 1
    @time_label.textColor = CBLightWhiteColor
    @time_label.setFont UIFont.fontWithName(CBRegularFontName, size:12.0)
    @time_label.text = "now"
    
    add_yes_no_buttons
    
    self.contentView.addSubview @time_label
    self.contentView.addSubview @message_container
    self.contentView.addSubview @profile_image_view
    
    self
  end
  
  def add_yes_no_buttons
    @buttons_container = UIView.alloc.init
    
    @yes_button = UIButton.buttonWithType UIButtonTypeCustom
    @yes_button.frame = [[0, 0], [CBYesNoButtonWidth, CBYesNoButtonHeight]]
    @yes_button.addTarget self, action:"press_yes_button", forControlEvents:UIControlEventTouchUpInside
    @yes_button.setTitle "YES", forState:UIControlStateNormal
    @yes_button.titleLabel.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    @yes_button.setTitleColor UIColor.whiteColor, forState:UIControlStateNormal
    @yes_button.backgroundColor    = CBYellowColor
    @yes_button.layer.borderColor  = UIColor.whiteColor.CGColor
    @yes_button.layer.borderWidth  = 0.5
    @yes_button.layer.cornerRadius = CBRoundedCornerRadius
    @buttons_container.addSubview @yes_button
    
    @no_button = UIButton.buttonWithType UIButtonTypeCustom
    @no_button.frame = [[@yes_button.size.width+10, 0], [CBYesNoButtonWidth, CBYesNoButtonHeight]]
    @no_button.addTarget self, action:"press_no_button", forControlEvents:UIControlEventTouchUpInside
    @no_button.setTitle "NO", forState:UIControlStateNormal
    @no_button.titleLabel.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    @no_button.setTitleColor UIColor.whiteColor, forState:UIControlStateNormal
    @no_button.backgroundColor    = CBYellowColor
    @no_button.layer.borderColor  = UIColor.whiteColor.CGColor
    @no_button.layer.borderWidth  = 0.5
    @no_button.layer.cornerRadius = CBRoundedCornerRadius
    @buttons_container.addSubview @no_button
    
    @message_container.addSubview @buttons_container
  end
  
  def get_height_of_message_object(message_object)
    #message_object = message_object
    @message_label.text = message_object[:text]
    @message_label.setVerticalAlignmentTopWithConstraintSize @message_label_constraint_size
    
    message_cell_height = @message_label.size.height+CBMessagePadding*2+CBMessagePadding
    if message_object[:is_question]
      message_cell_height = message_cell_height+CBYesNoButtonHeight+CBMessagePadding
    end
    
    message_cell_height
  end
  
  def message_object=(message_object)
    @message_object = message_object
    
    @message_label.text = message_object[:text]
    @message_label.setVerticalAlignmentTopWithConstraintSize @message_label_constraint_size
    
    @direction       = message_object[:direction]
    @time_label.text = message_object[:time_text]
    @is_question     = message_object[:is_question]
    
    update_view
  end
    
  def update_view
    message_container_width = @message_label.size.width+CBMessagePadding*2+CBMessageProfileImageWidth
    
    if @is_question
      @buttons_container.hidden = false
      @buttons_container.frame = [
        [CBMessageProfileImageWidth, @message_label.origin.y+@message_label.size.height+CBMessagePadding],
        [button_container_width, CBYesNoButtonHeight]]
        
      message_container_size = [message_container_width, 
        @buttons_container.origin.y+@buttons_container.size.height+CBMessagePadding]
    else
      @buttons_container.hidden = true  
      message_container_size = [message_container_width, @message_label.size.height+CBMessagePadding*2]
    end
    
    if @direction == 'left'
      @message_container.frame = [[CBMessagePadding, 0], message_container_size]
        
      @message_label.origin = [CBMessageProfileImageWidth, CBMessagePadding]
      @time_label.origin    = [@message_container.origin.x+@message_container.size.width+5, 
        @message_container.size.height-CBMessageTimeLabelHeight]
      @time_label.textAlignment = NSTextAlignmentLeft
      @profile_image_view.image = CBRobotProfileImage
    else
      @message_container.frame = [[self.contentView.size.width-CBMessagePadding-message_container_width, 0], 
        message_container_size]
        
      @message_label.origin = [CBMessagePadding, CBMessagePadding]
      @time_label.origin    = [@message_container.origin.x-5-@time_label.size.width, 
        @message_container.size.height-CBMessageTimeLabelHeight]
      @time_label.textAlignment = NSTextAlignmentRight
      @profile_image_view.setImageWithURL NSURL.URLWithString(User.current.profile_image_url),
                         placeholderImage:nil
    end
    
    apply_rounded_corner_on_view @message_container
    self.contentView.frame = [self.contentView.origin, [self.contentView.size.width, @message_container.size.height+CBMessagePadding]]
    
    update_profile_image_view
  end
  
  def button_container_width
    default_button_container_width = 110
    if @message_label.size.width > default_button_container_width
      @message_label.size.width
    else
      default_button_container_width
    end
  end
  
  def update_profile_image_view
    if @direction == 'left'
      @profile_image_view.origin = [0, self.contentView.size.height-CBMessageProfileImageHeight]
    else
      @profile_image_view.origin = [self.contentView.size.width-CBMessageProfileImageWidth, self.contentView.size.height-CBMessageProfileImageHeight]
    end
  end
  
  def press_yes_button
    send_answer 'yes'
  end
  
  def press_no_button
    send_answer 'no'
  end
  
  def send_answer(answer)
    question = @message_object[:text]
    message  = answer
    request  = { :message => message, :mode => 'answer', :question => question, :user_id => User.current.user_id }
    Robot.instance.listen request
  end
end