class MessageBox < UIView
  include Style
  
  attr_accessor :delegate
  
  def initWithFrame(frame)
    super frame
    
    self.backgroundColor = UIColor.whiteColor
    @original_origin = self.frame.origin
    
    @message_text_field = UITextField.alloc.initWithFrame [[CBDefaultMargin, 0], 
          [self.size.width-CBDefaultMargin*2, self.size.height]]
    @message_text_field.clearButtonMode          = UITextFieldViewModeWhileEditing
    @message_text_field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
    @message_text_field.textAlignment            = UITextAlignmentLeft
    @message_text_field.attributedPlaceholder    = NSAttributedString.alloc.initWithString CBMessageBoxPlaceholderText, 
          attributes:{ NSForegroundColorAttributeName => CBLightGrayColor }
    @message_text_field.setReturnKeyType UIReturnKeySend
    @message_text_field.setFont UIFont.fontWithName(CBRegularFontName, size:20.0)
    @message_text_field.delegate = self
    self.addSubview @message_text_field
    
    apply_rounded_corner
    add_keyboard_observers
    add_tap_recognizer
    
    self
  end
  
  def add_tap_recognizer
    tap_recognizer = UITapGestureRecognizer.alloc.initWithTarget self, action:"tap_on_box"
    self.addGestureRecognizer tap_recognizer
  end
  
  def tap_on_box
    @message_text_field.becomeFirstResponder
  end
  
  def add_keyboard_observers
    NSNotificationCenter.defaultCenter.addObserver self,
                                             selector:"keyboard_will_show:",
                                                 name:UIKeyboardWillShowNotification,
                                               object:nil
    NSNotificationCenter.defaultCenter.addObserver self,
                                             selector:"keyboard_will_hide:",
                                                 name:UIKeyboardWillHideNotification,
                                               object:nil
  end
  
  def remove_keyboard_observers
    NSNotificationCenter.defaultCenter.removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
    NSNotificationCenter.defaultCenter.removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
  end
  
  def keyboard_will_show(notification)
    userInfo          = notification.userInfo    
    startFrame        = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey).CGRectValue
    endFrame          = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).CGRectValue
    animationCurve    = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey).intValue
    animationDuration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey).doubleValue
    
    show_messages_view
    
    UIView.animateWithDuration animationDuration,
                              delay:0,
                            options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState,
                         animations:(lambda do
                            self.origin = [@original_origin[0],
                              @original_origin[1] - endFrame.size.height]
                            update_messages_view_with_keyboard_height(endFrame.size.height)
                          end),
                         completion:nil
  end
  
  def keyboard_will_hide(notification)
    hide_messages_view
    
    userInfo          = notification.userInfo    
    startFrame        = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey).CGRectValue
    endFrame          = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).CGRectValue
    animationCurve    = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey).intValue
    animationDuration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey).doubleValue
    
    UIView.animateWithDuration animationDuration,
                              delay:0,
                            options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState,
                         animations:(lambda do
                            self.origin = @original_origin
                            update_messages_view_with_keyboard_height(0)
                          end),
                         completion:nil
  end
  
  def update_messages_view_with_keyboard_height(height)
    if @delegate && @delegate.respond_to?('update_frame_with_keyboard_height')
      @delegate.update_frame_with_keyboard_height(height)
    end
  end
  
  def show_messages_view
    if @delegate && @delegate.respond_to?('show_message_ui')
      @delegate.show_message_ui
    end
  end
  
  def hide_messages_view
    if @delegate && @delegate.respond_to?('hide_message_ui')
      @delegate.hide_message_ui
    end
  end
  
  def textFieldShouldReturn(text_field)
    message = text_field.text.strip
    if message != ""
      text_field.text = ""
      if @delegate && @delegate.respond_to?('message_box_did_send')
        @delegate.message_box_did_send(message)
      end
    end
  end
  
  def textFieldDidBeginEditing(text_field)
  end
  
  def textFieldDidEndEditing(text_field)
  end
  
  def dismiss_keyboard
    self.endEditing true
  end
end