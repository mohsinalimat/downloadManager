#
#  Be sure to run `pod spec lint SULoader.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DownloadManager"
  s.version      = "0.0.1"
  s.summary      = "A short description of DownloadManager"
  s.homepage     = "https://github.com/liudiange/downloadManager"
  s.license      = "MIT"
  s.author             = { "diange Liu" => "shaoyeliudiange@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liudiange/downloadManager.git", :tag => "v0.0.1" }
  s.source_files  = 'DownloadManages/*'
  s.framework  = "UIKit"
  s.dependency "AFNetworking", "~> 3.1.0"
  
  end
