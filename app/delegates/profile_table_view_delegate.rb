module ProfileTableViewDelegate
  
  def objects_of_table_view(table_view)
    if table_view == @fav_table_view
      @fav_objects
    elsif table_view == @event_table_view
      @event_objects
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    92 # 60 + 16*2
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath indexPath, animated:true
    
    objects = objects_of_table_view(tableView)
    object  = objects[indexPath.row]
    if tableView == @fav_table_view
      App.play_object_by_user object
      App.home_view_controller.press_logo_button
    elsif tableView == @event_table_view
      App.show_event_page object
    end
  end
  
  def tableView(tableView, heightForHeaderInSection:section)
    1
  end

  def tableView(tableView, viewForHeaderInSection:section)
    header_view = UIView.alloc.initWithFrame CGRectMake(0, 0, tableView.size.width, 1)
    header_view.backgroundColor = UIColor.colorWithRed 221/255.0, green:221/255.0, blue:221/255.0, alpha:1.0

    header_view
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuseIdentifier ||= CBSongTableCellReuseIdentifier

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      SongTableCell.alloc.init
    end
    
    objects = objects_of_table_view(tableView)
    object  = objects[indexPath.row]
    
    if tableView == @fav_table_view
      placeholder_image = CBDefaultSongImage
    elsif tableView == @event_table_view
      placeholder_image = CBDefaultEventImage
    end
    
    if object
      cell.image_view.setImageWithURL NSURL.URLWithString(object[:image_url]),
                     placeholderImage:placeholder_image
  
      cell.update_images_with_source object[:source]
      cell.title_label.text    = object[:title]
      cell.subtitle_label.text = object[:subtitle]
    end
    
    cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
    objects = objects_of_table_view(tableView)
    objects.count
  end

  def tableView(tableView, titleForHeaderInSection:section)
    ""
  end
  
  def numberOfSectionsInTableView(tableView)
    objects = objects_of_table_view(tableView)
    if objects.count != 0  
      tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
      return 1
    else
      if tableView == @fav_table_view
        image        = CBEmptyFavsImage
        image_height = CBEmptyFavsImageHeight
        image_width  = CBEmptyFavsImageWidth
        message_text = "The more you like, the better \nmatches you can get from me"
      elsif tableView == @event_table_view
        image        = CBEmptyEventsImage
        image_height = CBEmptyEventsImageHeight
        image_width  = CBEmptyEventsImageWidth
        message_text = "Start bookmarking events and \ndiscover the hidden music in your life"
      end
      
      background_view = UIView.alloc.initWithFrame [[0, 0], tableView.size]
      
      image_view = UIImageView.alloc.initWithFrame [[(view.size.width-image_width)/2, 0], [image_width, image_height]]
      image_view.image = image
      
      message_label               = UILabel.alloc.initWithFrame [[0, 0], self.view.size]
      message_label.text          = message_text
      message_label.textColor     = CBLightGrayColor
      message_label.numberOfLines = 0
      message_label.textAlignment = NSTextAlignmentCenter
      message_label.font = UIFont.fontWithName(CBRegularFontName, size:14.0)
      message_label.sizeToFit
      
      origin_y = (tableView.size.height - image_view.size.height - 10 - message_label.size.height - 40)/2
      image_view.origin   = [image_view.origin.x, origin_y]
      message_label.frame = [[(view.size.width-message_label.size.width)/2, image_view.origin.y+image_view.size.height+10],
        message_label.size]
              
      background_view.addSubview image_view
      background_view.addSubview message_label
        
      tableView.backgroundView = background_view
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone
      return 0
    end
  end
  
end