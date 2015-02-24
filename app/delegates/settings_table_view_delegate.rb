module SettingTableViewDelegate
  
  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    if tableView.respondsToSelector "setSeparatorInset:"
      tableView.setSeparatorInset UIEdgeInsetsZero
    end

    if tableView.respondsToSelector "setLayoutMargins:"
      tableView.setLayoutMargins UIEdgeInsetsZero
    end
    
    if cell.respondsToSelector "setLayoutMargins:"
      cell.setLayoutMargins UIEdgeInsetsZero
    end
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuseIdentifier ||= CBSettingsCellReuseIdentifier

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      SettingsTableCell.alloc.init
    end
    cell.selectionStyle = UITableViewCellSelectionStyleDefault
    
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        cell.selectionStyle   = UITableViewCellSelectionStyleNone
        cell.title_label.text = "Version"
        cell.detail_label.text = "2.0.0"
      when 1
        if User.current.is_logged_in?
          cell.title_label.text = "Sign Out"
        else
          cell.title_label.text = "Sign In"
        end
        cell.detail_label.text = ""
      end
    end

    cell
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        tableView.deselectRowAtIndexPath indexPath, animated:false
      when 1
        tableView.deselectRowAtIndexPath indexPath, animated:true
        
        if User.current.is_logged_in?
          NSLog "Sign Out Successfully"
        else
          NSLog "Go to Sign In page"
        end
      end
    end
  end
  
  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    CBSettingsCellHeight
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when 0
      2
    end
  end
  
  def tableView(tableView, titleForHeaderInSection:section)
    #case section
    #when 0
    #  'Account'
    #end
  end
  
end