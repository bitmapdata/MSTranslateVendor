Pod::Spec.new do |s|
  s.name         = "MSTranslateVendor"
  s.version      = "1.0.0"
  s.summary      = "Microsoft Translate API for iOS"
  s.homepage     = "http://github.com/bitmapdata/MSTranslateVendor"
  s.license      = { :type => 'BSD' }
  s.author       = { "bitmapdata" => "bitmapdata.com@gmail.com" }
  s.source       = { :git => "https://github.com/bitmapdata/MSTranslateVendor.git", :tag => "1.0.0" }
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
  s.ios.deployment_target = "4.3"
end
