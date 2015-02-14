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
  app.version           = '1.2'
  app.identifier        = 'com.songio.Cabl'
  app.seed_id           = '88A5HCG4W3'
  
  app.entitlements['application-identifier'] = app.seed_id + '.' + app.identifier
  
  # Facebook
  app.info_plist['CFBundleURLTypes'] = [ { 'CFBundleURLSchemes' => ['fb964305206928472', 'cable-app'] } ] 
  app.info_plist['FacebookAppID']    = '964305206928472'
  
  app.fonts = ['fonts/OpenSans-Regular.ttf', 'fonts/OpenSans-Light.ttf']
  app.fonts += ['fonts/ProximaNova-Regular.ttf', 'fonts/ProximaNova-Light.ttf']
  
  # LBYouTubeView
  app.vendor_project('vendor/LBYouTubeView', :static, :cflags => "-fobjc-arc")
  
  app.pods do
    pod 'SDWebImage'
    pod 'XCDYouTubeKit'
    pod 'Firebase', '>= 2.1.2'
    pod 'KVOController'
    pod 'AFNetworking'
    pod 'Parse'
    pod 'ParseFacebookUtils'
    pod 'Facebook-iOS-SDK'
  end
  
  app.info_plist['UIBackgroundModes'] = ['audio', 'remote-notification']
  
end
