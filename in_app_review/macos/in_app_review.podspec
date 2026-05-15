#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint in_app_review.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'in_app_review'
  s.version          = '2.0.0'
  s.summary          = 'Flutter plugin for showing the In-App Review/System Rating pop up.'
  s.description      = <<-DESC
Flutter plugin for showing the In-App Review/System Rating pop up.
                       DESC
  s.homepage         = 'https://pub.dev/packages/in_app_review'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Britannio Jarrett' => 'oss@britannio.dev' }

  s.source           = { :path => '.' }
  s.source_files = 'in_app_review/Sources/in_app_review/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'in_app_review_privacy' => ['in_app_review/Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
