module EventsTableViewDelegate

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    92 # 60 + 16*2
  end
  
  def objects_of_table_view(table_view)
    if table_view == @recommended_table_view
      recommended_objects
    elsif table_view == @bookmarked_table_view
      bookmarked_objects
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
    @reuseIdentifier ||= CBSongTableCellReuseIdentifier

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      SongTableCell.alloc.init
    end
    
    objects = objects_of_table_view(tableView)
    object  = objects[indexPath.row]
    cell.image_view.setImageWithURL NSURL.URLWithString(object[:image_url]),
                   placeholderImage:nil
  
    cell.update_images_with_source object[:source]                
    cell.title_label.text    = object[:title]
    cell.subtitle_label.text = object[:subtitle]

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