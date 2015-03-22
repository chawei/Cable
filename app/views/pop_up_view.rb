class PopUpView < UIView
  
  def init_with_origin(origin, with_song_object:song_object)
    init
    
    self
  end
  
  def self.option_titles
    titles = [CBCopyLinkTitle]
    titles << CBShareByMailTitle if MFMailComposeViewController.canSendMail
    titles << CBShareBySMSMessageTitle if MFMessageComposeViewController.canSendText
    titles << CBShareToWhatsAppTitle if canOpenWhatsApp
    titles << CBShareToFBMessengerTitle if canOpenFBMessengerApp
    titles << CBPostOnFBTitle if canOpenFacebookApp
    
    titles.reverse
  end
  
  def self.share_song(song_object)
    @song_object = song_object
    
    titles = option_titles
    options_section = JGActionSheetSection.sectionWithTitle nil, message:nil, buttonTitles:titles,
      buttonStyle:JGActionSheetButtonStyleDefault
    cancel_section  = JGActionSheetSection.sectionWithTitle nil, message:nil, buttonTitles:[CBCancelTitle],
      buttonStyle:JGActionSheetButtonStyleCancel

    sections = [options_section, cancel_section]
    sheet    = JGActionSheet.actionSheetWithSections sections

    sheet.setButtonPressedBlock(lambda do |sheet, indexPath|
      if indexPath.section == 0
        if button = sheet.sections[0].buttons[indexPath.row]
          title = button.titleLabel.text
          press_on_button_with_title title
        end
      end
      sheet.dismissAnimated true
    end)
    
    sheet.showInView UIApplication.sharedApplication.keyWindow, animated:true
  end
  
  def self.share_song_using_default_ui(song_object)
    @song_object = song_object
    
    @share_action_sheet = UIActionSheet.alloc.initWithTitle(nil, 
      delegate:self,
      cancelButtonTitle:nil,
      destructiveButtonTitle:nil,
      otherButtonTitles:nil)

    titles = option_titles
    titles.each do |title|
      @share_action_sheet.addButtonWithTitle title
    end
    @share_action_sheet.addButtonWithTitle "Cancel"
    @share_action_sheet.cancelButtonIndex = titles.count
    
    @share_action_sheet.actionSheetStyle = UIActionSheetStyleDefault
    @share_action_sheet.showInView UIApplication.sharedApplication.keyWindow
  end
  
  def self.actionSheet(actionSheet, clickedButtonAtIndex:buttonIndex)
    if actionSheet == @share_action_sheet
      title = @share_action_sheet.buttonTitleAtIndex(buttonIndex)
      press_on_button_with_title title 
      
      #MixpanelClient.trackSharingAction option
    end
  end
  
  def self.press_on_button_with_title(title)
    case title
    when CBCopyLinkTitle
      copy_link
    when CBShareToFBMessengerTitle
      compose_fb_message @song_object
    when CBPostOnFBTitle
      share_via_fb_dialog @song_object
    when CBShareToWhatsAppTitle
      share_via_whatsapp @song_object
    when CBShareByMailTitle
      share_via_mail @song_object
    when CBShareBySMSMessageTitle
      share_via_sms @song_object
    end
  end
  
  def self.copy_link
    if @song_object
      @song_object.copy_link
      Robot.instance.queue_message_text CBCopyLinkMessage
    end
  end
  
  def self.share_via_whatsapp(song_object)
    title   = song_object.title
    videoID = song_object.video_id
    link    = song_object.cable_link
    
    text    = "Check this out! #{title} - #{link}"
    escaped = CFURLCreateStringByAddingPercentEscapes(nil, text, nil, "!*'();:@&=+$,/?%#[]",
                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
    whatsapp_url = NSURL.URLWithString "whatsapp://send?text=#{escaped}"
    if UIApplication.sharedApplication.canOpenURL(whatsapp_url)
      UIApplication.sharedApplication.openURL whatsapp_url
    end
  end
  
  def self.share_via_mail(song_object)
    if MFMailComposeViewController.canSendMail
      title   = song_object.title
      videoID = song_object.video_id
      link    = song_object.cable_link
      body    = "<div>I'm listening to \"#{title}\"</div><br><div>Listen here: <a href='#{link}'>#{link}</a></div>"
      
      compose_view_controller = MFMailComposeViewController.alloc.initWithNibName nil, bundle:nil
      compose_view_controller.setMailComposeDelegate App.home_view_controller
      compose_view_controller.setSubject "Check out this song on Cable"
      compose_view_controller.setMessageBody body, isHTML:true
      App.home_view_controller.presentViewController compose_view_controller, animated:true, completion:nil
    end
  end
  
  def self.share_via_sms(song_object) 
    title   = song_object.title
    videoID = song_object.video_id
    link    = song_object.cable_link
    
    text    = "Check out this song on Cable!\n#{title} - #{link}"
    send_sms(text, to:nil, in_view_controller:App.home_view_controller)
  end
  
  def self.send_sms(message, to:recipientNumbers, in_view_controller:view_controller)
    if MFMessageComposeViewController.canSendText
      mvc = MFMessageComposeViewController.alloc.init
      if recipientNumbers
        mvc.recipients = recipientNumbers
      end
      mvc.body                   = message
      mvc.messageComposeDelegate = view_controller
      view_controller.presentViewController mvc, animated:true, completion:nil
    else
      alert_view = UIAlertView.alloc.initWithTitle("Error",
                                message:"Device doesn't support text messages",
                                delegate:nil,
                                cancelButtonTitle:"OK",
                                otherButtonTitles:nil)
                                
      alert_view.show
    end
  end
  
  def self.share_via_fb_dialog(song_object)
    title   = song_object.title
    videoID = song_object.video_id
    link    = song_object.cable_link
    
    params      = FBLinkShareParams.alloc.init
    params.link = NSURL.URLWithString link

    # If the Facebook app is installed and we can present the share dialog
    if FBDialogs.canPresentShareDialogWithParams(params)
      # Present the share dialog
      FBDialogs.presentShareDialogWithLink params.link,
                                    handler:(lambda do |call, results, error|
                                      if error
                                        NSLog "Error publishing story: #{error.description}"
                                      else
                                        NSLog "results: #{results}" 
                                      end
                                    end)
    else
      # Present the feed dialog
      NSLog "FBDialogs cannot PresentShareDialogWithParams"
    end
  end
  
  def self.compose_fb_message(song_object)
    title    = song_object.title
    videoID  = song_object.video_id
    link     = song_object.cable_link
    imageUrl = song_object.image_url
    
    #action = FBGraphObject.graphObject
    #video  = FBGraphObject.openGraphObjectForPostWithType "video.other",
    #                     title:title,
    #                     image:imageUrl,
    #                     url:link,
    #                     description:""
    #video["data"]   = { "youTubeId" => "#{videoID}" }
    #action["video"] = video
    #
    #params = FBOpenGraphActionShareDialogParams.alloc.init
    #params.action = action
    #params.previewPropertyName = "video"
    #params.actionType = "video.watches"
    #
    #FBDialogs.presentMessageDialogWithOpenGraphActionParams params,
    #                                            clientState:nil,
    #                                                handler:(lambda do |call, results, error|
    #                                                  if error
    #                                                    # TODO: Handle errors
    #                                                  else
    #                                                    NSLog "results: #{results}" 
    #                                                  end
    #                                                end)
    
    params         = FBLinkShareParams.alloc.init
    params.name    = title
    params.caption = title
    params.linkDescription = "Cable - A new way to discover music."
    params.link            = NSURL.URLWithString link
    params.picture         = NSURL.URLWithString imageUrl
    FBDialogs.presentMessageDialogWithParams params,
                                 clientState:nil,
                                     handler:(lambda do |call, results, error|
                                       if error
                                         # TODO: Handle errors
                                       else
                                         NSLog "results: #{results}" 
                                       end
                                     end)
  end
  
  def self.canOpenWhatsApp
    canOpenAppWithSchemeName("whatsapp")
  end
  
  def self.canOpenFacebookApp
    canOpenAppWithSchemeName("fb")
  end
  
  def self.canOpenFBMessengerApp
    canOpenAppWithSchemeName("fb-messenger")
  end
  
  def self.canOpenAppWithSchemeName(name)
    urlApp       = NSURL.URLWithString "#{name}://"
    canOpenFBApp = UIApplication.sharedApplication.canOpenURL urlApp
  end
end