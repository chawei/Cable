# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name              = 'Cable'
  app.deployment_target = '7.0'
  app.version           = '1.3.4'
  app.identifier        = 'com.songio.Cabl'
  app.seed_id           = '88A5HCG4W3'
  
  app.entitlements['application-identifier'] = app.seed_id + '.' + app.identifier
  
  app.development do
    app.entitlements['aps-environment'] = 'development'
    app.entitlements['get-task-allow']  = true
    app.provisioning_profile = '/Users/chawei/Library/MobileDevice/Provisioning Profiles/CableApp_Development.mobileprovision'
    app.codesign_certificate = 'iPhone Developer: David Hsu (PFBJ39PZ74)'
  end
  
  app.release do
    app.entitlements['aps-environment'] = 'production'
    app.entitlements['get-task-allow']  = false
    app.provisioning_profile = '/Users/chawei/Library/MobileDevice/Provisioning Profiles/Team_Cabl.mobileprovision'
    app.codesign_certificate = 'iPhone Distribution: David Hsu (88A5HCG4W3)'
    app.entitlements['beta-reports-active'] = true
  end
  
  #app.target "./WatchApp", :extension
  
  # Facebook
  app.info_plist['CFBundleURLTypes'] = [ { 'CFBundleURLSchemes' => ['fb964305206928472', 'cable-app'] } ] 
  app.info_plist['FacebookAppID']    = '964305206928472'
  
  app.icons = ['Icon-60@2x.png', 'Icon-60.png']
  
  app.fonts = ['fonts/OpenSans-Regular.ttf', 'fonts/OpenSans-Light.ttf']
  app.fonts += ['fonts/ProximaNova-Regular.ttf', 'fonts/ProximaNova-Light.ttf']
  
  # Cable
  app.frameworks += [
    'CoreText',
    'CoreGraphics',
    'Foundation',
    'QuartzCore',
    'Security',
    'SystemConfiguration',
    'UIKit',
    'AVFoundation',
    'MessageUI',
    'MapKit']
  
  # LBYouTubeView
  app.vendor_project('vendor/LBYouTubeView', :static, :cflags => "-fobjc-arc")
  
  # DWTagList
  app.vendor_project('vendor/DWTagList', :static, :cflags => "-fobjc-arc")
  
  # JGActionSheet
  app.vendor_project('vendor/JGActionSheet', :static, :cflags => "-fobjc-arc")
  
  app.pods do
    pod 'SDWebImage'
    pod 'XCDYouTubeKit'
    pod 'Firebase', '>= 2.1.2'
    pod 'KVOController'
    pod 'AFNetworking'
    pod 'Parse'
    pod 'ParseFacebookUtils'
    pod 'Facebook-iOS-SDK'
    pod 'HockeySDK'
    pod 'TTTAttributedLabel'
    pod 'TOWebViewController'
    pod 'youtube-ios-player-helper', '~> 0.1.1'
    pod 'NAKPlaybackIndicatorView'
  end
  
  app.info_plist['UIBackgroundModes'] = ['audio', 'remote-notification']
  
end
