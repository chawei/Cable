class SongTableCell < UITableViewCell
  attr_accessor :title_label
  attr_accessor :subtitle_label
  attr_accessor :image_view
  attr_accessor :source_image_view
  
  def init
    initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CBSongTableCellReuseIdentifier)
    
    @image_view = UIImageView.alloc.initWithImage CBDefaultProfileImage
    @image_view.contentMode = UIViewContentModeScaleAspectFit
    @image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [60, 60]]
    
    @source_image_view = UIImageView.alloc.initWithImage CBYouTubeIconImage
    @source_image_view.frame = [[CBDefaultMargin+60-13, CBDefaultMargin-3], [16, 16]]
    
    @title_label = UILabel.alloc.init
    @title_label.numberOfLines = 2
    @title_label.textColor = UIColor.blackColor
    @title_label.setFont UIFont.fontWithName(CBRegularFontName, size:16.0)
    @title_label.text = "Unknown Title"
      
    @subtitle_label = UILabel.alloc.init
    @subtitle_label.textColor = UIColor.grayColor
    @subtitle_label.setFont UIFont.fontWithName(CBLightFontName, size:12.0)
    @subtitle_label.text = "Sub Title"
        
    self.addSubview @image_view
    self.addSubview @source_image_view
    self.addSubview @title_label
    self.addSubview @subtitle_label
    
    self
  end
  
  def layoutSubviews
    super
    
    label_origin_x = @image_view.frame.origin.x+@image_view.size.width+CBDefaultMargin
    @title_label.frame = [[label_origin_x, CBCellLabelTopMargin], 
      [self.size.width-label_origin_x-CBDefaultMargin, CBTitleLabelHeight]]
    @title_label.setVerticalAlignmentTopWithHeight(CBTitleLabelHeight)
    @subtitle_label.frame = [[label_origin_x, @title_label.frame.origin.y+@title_label.size.height], 
      [self.size.width-label_origin_x-CBDefaultMargin, 20]]
  end
  
  def update_images_with_source(source)
    if source == 'youtube'
      @source_image_view.image = CBYouTubeIconImage
      @image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [60, 40]]
    elsif source == 'spotify'
      @source_image_view.image = CBSpotifyIconImage
      @image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [60, 60]]
    else
      @source_image_view.image = nil
      @image_view.frame = [[CBDefaultMargin, CBDefaultMargin], [60, 60]]
    end
  end
end