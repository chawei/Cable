class MessageBox < UIView
  include Style
  
  attr_accessor :delegate
  
  def initWithFrame(frame)
    super frame
    
    self.backgroundColor = UIColor.whiteColor
    @original_origin = self.frame.origin
    
    @message_text_field = UITextField.alloc.initWithFrame [[CBDefaultMargin, CBDefaultMargin], 
          [self.size.width-CBDefaultMargin*2, self.size.height-CBDefaultMargin*2]]
    @message_text_field.clearButtonMode          = UITextFieldViewModeWhileEditing
    @message_text_field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
    @message_text_field.textAlignment            = UITextAlignmentLeft
    @message_text_field.attributedPlaceholder    = NSAttributedString.alloc.initWithString CBMessageBoxPlaceholderText, 
          attributes:{ NSForegroundColorAttributeName => UIColor.grayColor }
    @message_text_field.setReturnKeyType UIReturnKeySend
    @message_text_field.setFont UIFont.fontWithName(CBRegularFontName, size:20.0)
    @message_text_field.delegate = self
    self.addSubview @message_text_field
    
    apply_rounded_corner
    
    add_keyboard_observers
    
    self
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
    show_messages_view
    
    userInfo          = notification.userInfo    
    startFrame        = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey).CGRectValue
    endFrame          = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).CGRectValue
    animationCurve    = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey).intValue
    animationDuration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey).doubleValue
    
    UIView.animateWithDuration animationDuration,
                              delay:0,
                            options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState,
                         animations:(lambda do
                            self.origin = [@original_origin[0],
                              @original_origin[1] - endFrame.size.height]
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
                          end),
                         completion:nil
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
    if text_field.text.strip != ""
      if @delegate && @delegate.respond_to?('message_box_did_send')
      end
    end
    
    dismiss_keyboard
  end
  
  def textFieldDidBeginEditing(text_field)
  end
  
  def textFieldDidEndEditing(text_field)
  end
  
  def dismiss_keyboard
    self.endEditing true
  end
end