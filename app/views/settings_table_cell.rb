class SettingsTableCell < UITableViewCell
  
  attr_accessor :title_label
  attr_accessor :detail_label
  
  def init
    initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CBSettingsCellReuseIdentifier)
    
    @title_label = UILabel.alloc.init
    @title_label.textAlignment = NSTextAlignmentLeft
    @title_label.numberOfLines = 1
    @title_label.textColor = UIColor.blackColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    
    self.addSubview @title_label
    
    @detail_label = UILabel.alloc.init
    @detail_label.textAlignment = NSTextAlignmentRight
    @detail_label.numberOfLines = 1
    @detail_label.textColor = UIColor.blackColor
    @detail_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    
    self.addSubview @detail_label
     
    self
  end
  
  def layoutSubviews
    super
    
    cell_inner_width   = self.size.width-CBDefaultMargin*3
    title_label_width  = cell_inner_width/3*2
    detail_label_width = cell_inner_width - title_label_width
    
    @title_label.frame  = [[CBDefaultMargin, 0], [title_label_width, CBSettingsCellHeight]]
    @detail_label.frame = [[title_label_width+CBDefaultMargin*2, 0], [detail_label_width, CBSettingsCellHeight]]
  end
end