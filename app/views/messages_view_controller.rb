class MessagesViewController < UICollectionViewController
  attr_accessor :controller
  
  def init_with_params(params)
    @max_width       = params[:max_width]
    @original_frame  = params[:frame]
    @original_height = @original_frame[1][1]
    @message_objects = []
    
    flow_layout = UICollectionViewFlowLayout.alloc.init
    flow_layout.setItemSize CGSizeMake(@max_width, 100)
    initWithCollectionViewLayout flow_layout
    
    return self
  end
  
  def template_cell
    if @template_cell.nil? && @max_width
      @template_cell = MessageViewCell.alloc.initWithFrame([[0, 0], [@max_width, 100]])
    end
    @template_cell
  end
  
  def update_content_view_frame
    update_content_inset
    scroll_to_bottom
  end
  
  def update_content_inset
    total_height = 0
    message_count = 0
    message_objects.each do |message_object|
      height = template_cell.get_height_of_message_object(message_object)
      total_height += height
      message_count += 1
      if total_height > collectionView.size.height - CBMessageMargin*(message_count-1)
        break
      end
    end
    top_inset = collectionView.size.height - total_height - CBMessageMargin*(message_count-1)
    #NSLog "top_inset: #{top_inset} total_height: #{total_height}"
    if top_inset > 0
      collectionView.setContentInset UIEdgeInsetsMake(top_inset, 0, 0, 0)
    else
      collectionView.setContentInset UIEdgeInsetsMake(0, 0, 0, 0)
    end
  end
  
  def scroll_to_bottom
    last_index = message_objects.count - 1
    if last_index >= 0
      index_path = NSIndexPath.indexPathForRow last_index, inSection:0
      collectionView.scrollToItemAtIndexPath index_path, atScrollPosition:UICollectionViewScrollPositionBottom, animated:false
    end
  end
  
  def viewDidLoad
    super
    
    collectionView.registerClass MessageViewCell, forCellWithReuseIdentifier:CBMessageCellReuseIdentifier
    collectionView.alwaysBounceVertical = true
    
    collectionView.backgroundColor = UIColor.clearColor
    collectionView.frame = @original_frame
    
    add_tap_recognizer
  end
  
  def add_tap_recognizer
    #background_view = UIView.alloc.initWithFrame @original_frame
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_background"
    #background_view.addGestureRecognizer tap_recognizer
    #collectionView.backgroundView = background_view
    collectionView.addGestureRecognizer tap_recognizer
  end
  
  def update_frame_with_keyboard_height(keyboard_height)
    if keyboard_height == 0
      collectionView.frame = @original_frame
    else
      collectionView.frame = [collectionView.origin, [collectionView.size.width, @original_height-keyboard_height]]
    end
    
    update_content_view_frame
  end
  
  def tap_background
    if @controller && @controller.respond_to?('hide_message_ui')
      @controller.hide_message_ui
    end
  end
  
  def mock_message_objects
    @message_objects = [{
      :type => 'text',
      :text => "Got a pretty exciting event that you might be interested!",
      :time_text => "12:49 PM",
      :direction => 'right'
    }, {
      :type => 'text',
      :text => "Got a pretty exciting event that you might be interested!",
      :time_text => "12:49 PM",
      :direction => 'left'
    }, {
      :type => 'text',
      :text => "Got a pretty exciting event that you might be interested!",
      :time_text => "12:49 PM",
      :direction => 'left'
    }, {
      :type => 'text',
      :text => "Got a pretty exciting event that you might be interested!",
      :time_text => "12:49 PM",
      :direction => 'right'
    }]
  end
  
  def reset_message_objects
    @message_objects = []
    
    collectionView.reloadData
  end
  
  def message_objects
    @message_objects
  end
  
  def show_message_object(message_object)
    @message_objects << message_object
    
    collectionView.reloadData
    update_content_view_frame
  end
  
  def show_responding_status
    message_object = {
      :type => 'responding',
      :text => 'typing...',
      :time_text => "",
      :direction => 'left'
    }
    show_message_object message_object
  end
  
  def hide_responding_status
    message_object = @message_objects[-1]
    if message_object && message_object[:type] == 'responding'
      @message_objects.delete_at(-1)
    end
    collectionView.reloadData
    update_content_view_frame
  end
  
  def send_message(message)
    message_object = {
      :type => 'text',
      :text => message,
      :time_text => "now",
      :direction => 'right'
    }
    
    show_message_object(message_object)
  end
  
  def collectionView(collectionView, numberOfItemsInSection:section)
    message_objects.count
  end
  
  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    message_object = message_objects.objectAtIndex indexPath.row
    template_cell.message_object = message_object
    
    return template_cell.contentView.size
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier CBMessageCellReuseIdentifier, forIndexPath:indexPath
    
    message_object = message_objects.objectAtIndex indexPath.row
    cell.message_object = message_object
    
    cell
  end
  
end