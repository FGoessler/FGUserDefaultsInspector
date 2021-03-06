Pod::Spec.new do |s|
  s.name             = "FGUserDefaultsInspector"
  s.version          = "1.1"
  s.summary          = "Explore and edit values inside your NSUserDefaults without the need of a debugger."
  s.homepage         = "https://github.com/FGoessler/FGUserDefaultsInspector"
  s.license          = 'MIT'
  s.author           = { "Goessler, Florian" => "florian.goessler@immobilienscout24.de" }
  s.source           = { :git => "https://github.com/FGoessler/FGUserDefaultsInspector.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'UIKit'
end
