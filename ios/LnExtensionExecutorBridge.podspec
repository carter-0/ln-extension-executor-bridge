Pod::Spec.new do |s|
  s.name           = 'LnExtensionExecutorBridge'
  s.version        = '1.0.0'
  s.summary        = 'React Native bridge for LNExtensionExecutor'
  s.description    = 'A React Native bridge for LNExtensionExecutor, allowing direct execution of iOS app extensions'
  s.author         = 'carter-0'
  s.homepage       = 'https://docs.expo.dev/modules/'
  s.platforms      = {
    :ios => '15.1'
  }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_VERSION' => '5.0'
  }

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
end
