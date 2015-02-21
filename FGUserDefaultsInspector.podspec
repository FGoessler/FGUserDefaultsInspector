Pod::Spec.new do |s|
  s.name             = "FGUserDefaultsInspector"
  s.version          = "0.1.0"
  s.summary          = "Easily inspect the contents of your NSUserDefaults in your app at runtime."
  s.homepage         = "https://github.com/FGoessler/FGUserDefaultsInspector"
  s.license          = 'MIT'
  s.author           = { "Goessler, Florian" => "florian.goessler@immobilienscout24.de" }
  s.source           = { :git => "https://github.com/FGoessler/FGUserDefaultsInspector.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'FGUserDefaultsInspector' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
end
