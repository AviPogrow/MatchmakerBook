platform :ios, '14.0'

target 'NasiShadchanHelper' do
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'ObjectMapper'
  pod 'Kingfisher'
  pod 'lottie-ios'
  pod 'GoogleSignIn'
  pod 'IQKeyboardManagerSwift'
  pod 'KMPlaceholderTextView'
  pod 'AAFloatingButton'
  pod 'Lightbox'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Eureka'
  pod 'ImageRow', '~> 4.0'
  pod 'ViewRow'

  target 'NasiShadchanHelperTests' do
    inherit! :search_paths
  end

  target 'NasiShadchanHelperUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end


