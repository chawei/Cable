module EventTableViewDelegate
  
  def event_data
    @event_data
  end
  
  def template_cell
    if @template_cell.nil?
      @template_cell = EventTableCell.alloc.init
    end
    @template_cell
  end
  
  def tableView(tableView, viewForHeaderInSection:section)
    header_view = UIView.alloc.initWithFrame [[0, 0], [self.size.width, 50]]
    
    header_view
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuseIdentifier ||= CBEventCellReuseIdentifier

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      EventTableCell.alloc.init
    end
    
    row_data = event_data[indexPath.row]
    cell.update_frame_with_data row_data

    cell
  end
  
  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    row_data = event_data[indexPath.row]
    
    template_cell.get_height_with_text(row_data[:detail])
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    event_data.length
  end
  
end