# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'LOLStats Monitor' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LOLStats Monitor
  pod 'Charts', :git => 'https://github.com/danielgindi/Charts'
  pod 'RealmSwift'
  pod 'SwiftyJSON'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end

end
