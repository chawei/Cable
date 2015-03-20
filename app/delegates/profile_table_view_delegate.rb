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

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    objects = objects_of_table_view(tableView)
    objects.count
  end

  def tableView(tableView, titleForHeaderInSection:section)
    ""
  end
  
end