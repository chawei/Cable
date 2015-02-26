module ShareDelegate
  
  def messageComposeViewController(controller, didFinishWithResult:result)
    self.dismissModalViewControllerAnimated true

    if result == MessageComposeResultSent
      message = "Message sent. Your friend will love it."
    elsif result == MessageComposeResultCancelled
      message = "Ugh... it's a great song. You should share to your friends!"
    else 
      message = "Hmm... something is wrong. I can't send it out!"
    end
    Robot.instance.queue_message_text(message)
  end
  
  def mailComposeController(controller, didFinishWithResult:result, error:error)
    self.dismissModalViewControllerAnimated true
    
    if result == MFMailComposeResultSent
      message = "Mail sent. Your friend will love it."
    elsif result == MFMailComposeResultSaved
      message = "Cool, I've saved it for you."
    elsif result == MFMailComposeResultCancelled
      message = "Ugh... it's a great song. You should share to your friends!"
    elsif result == MFMailComposeResultFailed
      message = "Hmm... something is wrong. I can't send it out!"
    end
    Robot.instance.queue_message_text(message)
  end
  
end