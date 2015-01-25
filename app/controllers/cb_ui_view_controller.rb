class CBUIViewController < UIViewController  
  def shouldAutorotate
    return false
  end

  def preferredInterfaceOrientationForPresentation
    return UIInterfaceOrientationPortrait
  end
  
  def supportedInterfaceOrientations
    return UIInterfaceOrientationMaskPortrait
  end
end