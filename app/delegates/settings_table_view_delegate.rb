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
        cell.selectionStyle    = UITableViewCellSelectionStyleNone
        cell.title_label.text  = "Version"
        cell.detail_label.text = App.version
      when 1
        if User.current.is_logged_in?
          cell.title_label.text = "Sign Out"
        else
          cell.title_label.text = "Connect to Facebook"
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
          close
          App.home_view_controller.show_home_view
          Robot.instance.send_logout_request
        else
          loading
          User.current.connect_to_facebook(lambda do 
            User.current.fetch_auth_data_and_establish_data_refs
            App.profile_view_controller.refresh_header_view
            tableView.reloadData
            finish_loading
          end)
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
  
  def loading
    @loading_view = UIView.alloc.initWithFrame self.view.frame
    @loading_view.backgroundColor = UIColor.colorWithRed 0/255.0, green:0/255.0, blue:0/255.0, alpha:0.24
    activity_view = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle UIActivityIndicatorViewStyleWhiteLarge
    activity_view.center = @loading_view.center
    activity_view.startAnimating
    @loading_view.addSubview activity_view
    @loading_view.layer.zPosition = 100
    
    self.view.addSubview @loading_view
  end
  
  def finish_loading
    @loading_view.removeFromSuperview
  end
  
end