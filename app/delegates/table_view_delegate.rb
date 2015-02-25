module TableViewDelegate
  
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
  
end