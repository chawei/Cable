module EventTableViewDelegate
  
  def event_data
    @event_data = [
      { :title => "Event name", :detail => event_object[:title] },
      { :title => "Event time", :detail => event_object[:event_time] },
      { :title => "Line up", :detail => event_object[:artist_name] },
      { :title => "Biographies", :detail => event_object[:bio] },
      { :title => "Official website", :detail => event_object[:link] }
    ]
  end
  
  def template_cell
    if @template_cell.nil?
      @template_cell = EventTableCell.alloc.init
    end
    @template_cell
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