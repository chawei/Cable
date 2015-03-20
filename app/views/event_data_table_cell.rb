class EventDataTableCell < UITableViewCell
  
  attr_accessor :title_label
  attr_accessor :detail_label
  
  def init
    initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CBEventDataCellReuseIdentifier)
    
    @title_label = UILabel.alloc.init
    @title_label.textAlignment = NSTextAlignmentLeft
    @title_label.numberOfLines = 1
    @title_label.textColor = CBLightGrayColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    
    self.addSubview @title_label
    
    @detail_label = TTTAttributedLabel.alloc.init
    @detail_label.delegate = self
    @detail_label.enabledTextCheckingTypes = NSTextCheckingTypeLink
    @detail_label.textAlignment = NSTextAlignmentLeft
    @detail_label.numberOfLines = 0
    @detail_label.textColor = UIColor.blackColor
    @detail_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    
    self.addSubview @detail_label
    
    self
  end
  
  def max_inner_width
    self.size.width-CBDefaultMargin*2
  end
  
  #def layoutSubviews
  #  super
  #  
  #  label_width = self.size.width-CBDefaultMargin*2
  #  @title_label.frame  = [[CBDefaultMargin, CBDefaultMargin], [label_width, 20]]
  #  @detail_label.frame = [[CBDefaultMargin, @title_label.origin.y+@title_label.size.height+8], [label_width, 20]]
  #end
  
  def update_frame_with_data(data)
    self.selectionStyle   = UITableViewCellSelectionStyleNone
    
    @title_label.text  = data[:title]
    @detail_label.text = data[:detail]
    @detail_label.setVerticalAlignmentTopWithConstraintSize [max_inner_width, 400]
    
    label_width = max_inner_width
    @title_label.frame  = [[CBDefaultMargin, CBDefaultMargin], [label_width, 20]]
    @detail_label.frame = [[CBDefaultMargin, @title_label.origin.y+@title_label.size.height+8], @detail_label.size]
  end
  
  def get_height_with_text(text)
    @detail_label.text = text
    @detail_label.setVerticalAlignmentTopWithConstraintSize [max_inner_width, 400]
    #NSLog "@detail_label.size.height #{@detail_label.size.height}"
    @detail_label_height = @detail_label.size.height
    
    CBDefaultMargin*2 + 20 + 8 + @detail_label_height
  end
  
  def attributedLabel(label, didSelectLinkWithURL:url)
    App.home_view_controller.showWebViewControllerWithUrl(url)
  end
end