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
  app.name = 'Cable'
  app.deployment_target = '7.0'
  
  app.fonts = ['fonts/OpenSans-Regular.ttf', 'fonts/OpenSans-Light.ttf']
  app.fonts += ['fonts/ProximaNova-Regular.ttf', 'fonts/ProximaNova-Light.ttf']
  

  
  app.pods do
    pod 'SDWebImage'
    pod 'XCDYouTubeKit'
    pod 'Firebase', '>= 2.1.2'
  end
  
end
