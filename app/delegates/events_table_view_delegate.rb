module EventsTableViewDelegate

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    92 # 60 + 16*2
  end
  
  def objects_of_table_view(table_view)
    if table_view == @recommended_table_view
      recommended_objects
    elsif table_view == @nearby_table_view
      nearby_objects
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath indexPath, animated:true
    
    objects = objects_of_table_view(tableView)
    object  = objects[indexPath.row]
    App.show_event_page object
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
    @reuseIdentifier ||= CBEventTableCellReuseIdentifier

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      EventTableCell.alloc.init
    end
    
    objects = objects_of_table_view(tableView)
    object  = objects[indexPath.row]
    
    cell.image_view.setImageWithURL NSURL.URLWithString(object[:image_url]),
                   placeholderImage:CBTransparentImage
  
    cell.update_images_with_source object[:source]                
    cell.title_label.text    = object[:title]
    cell.subtitle_label.text = object[:subtitle]

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
      image        = CBEmptyEventsImage
      image_height = CBEmptyEventsImageHeight
      image_width  = CBEmptyEventsImageWidth
      
      if tableView == @nearby_table_view
        message_text = "I can't find any event around you\nbut stay tuned!"
      elsif tableView == @recommended_table_view
        message_text = "I'm still finding events you might like.\n Play more so I can learn your taste!"
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