# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ScriptStarter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  $FirebaseSDKVersion = '7.1.0'

  # Pods for ScriptStarter
  pod 'Firebase/Core', $FirebaseSDKVersion
  pod 'Firebase/Auth', $FirebaseSDKVersion
  pod 'Firebase/Database', $FirebaseSDKVersion
  pod 'Firebase/DynamicLinks', $FirebaseSDKVersion
  pod 'GoogleSignIn', '~> 4.4.0'
  pod 'FBSDKLoginKit'
  pod 'FacebookLogin'
  pod 'MBProgressHUD', '~> 1.1.0'
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