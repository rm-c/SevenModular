#
# Be sure to run `pod lib lint SevenModular.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SevenModular'
  s.version          = '0.1.5'
  s.summary          = 'Seven模块公用库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rm-c/SevenModular'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CRM' => '904190328@qq.com' }
  s.source           = { :git => 'https://github.com/rm-c/SevenModular.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'SevenModular/Classes/**/*.{swift}'
  
  # s.resource_bundles = {
  #   'SevenModular' => ['SevenModular/Assets/*.png']
  # }
#  s.osx.vendored_framework = "PLCrashReporter-1.2-rc2/Mac OS X Framework/CrashReporter.framework"
#  s.osx.resource = "PLCrashReporter-1.2-rc2/Mac OS X Framework/CrashReporter.framework"
  s.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '@loader_path/../Frameworks' }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Foundation'
  s.vendored_frameworks = '**/**/*.framework'
  
  s.dependency 'WCDB.swift', '~> 1.0.8.2'
  s.dependency "ObjectMapper", '~> 4.2.0'
  s.dependency 'ZIPFoundation', '~> 0.9.11'
#  s.dependency 'iOSOTARTK', '~> 1.0.6'
  
end
