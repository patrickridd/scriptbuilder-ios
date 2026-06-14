# Uncomment the next line to define a global platform for your project
# platform :ios, '17.6'


target 'ScriptStarter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ScriptStarter
  pod 'KMPlaceholderTextView', '~> 1.4.0'

  target 'ScriptStarterTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ScriptStarterUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end