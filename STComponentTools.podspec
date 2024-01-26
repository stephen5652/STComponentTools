Pod::Spec.new do |spec|

  spec.name         = "STComponentTools"
  spec.version      = "0.0.1"
  spec.summary      = "STComponentTools 说明."
  spec.description      = <<-DESC
  STComponentTools long description of the pod here.
  DESC

  spec.homepage         = 'https://github.com/stephen5652/STComponentTools'
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "stephenchen" => "stephen5652@126.com" }
  spec.ios.deployment_target = '9.0'

  spec.source       = { :git => "https://github.com/stephen5652/STComponentTools.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.source_files = 'STComponentTools/{Public,Private}/**/*.{h,m,mm,c,cpp,swift}'
  # spec.exclude_files = "STComponentTools/Exclude" #排除文件

  # spec.project_header_files = 'STComponentTools/Private/**/*.{h}'
  # spec.public_header_files = 'STComponentTools/Public/**/*.h' #此处放置组件的对外暴漏的头文件

  # ――― binary framework/lib ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #spec.vendored_frameworks = 'STComponentTools/Private/**/*.framework'
  #spec.vendored_libraries = 'STComponentTools/Private/**/*.a'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # 放置 json,font,jpg,png等资源
  #  spec.resources = ["STComponentTools/{Public,Private}/**/*.{xib}"]
  #  spec.resource_bundles = {
  #    'STComponentTools' => ['STComponentTools/Assets/*.xcassets', "STComponentTools/{Public,Private}/**/*.{png,jpg,font,json}"]
  #  }


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  # 其他依赖pod
  # spec.dependency "XXXXXXXX"

  # STAnnotation
  spec.subspec 'STAnnotation' do |ss|
      ss.source_files = 'STComponentTools/STAnnotation/**/*.{h,m,mm,c,cpp,swift}'
      ss.public_header_files = 'STComponentTools/STAnnotation/Public/**/*.h' #此处放置组件的对外暴漏的头文件
#       ss.pod_target_xcconfig = {
#         'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YKHawkeyeWithLoad'
#       }
#       ss.dependency 'YKHawkeye/Core'
#       ss.vendored_frameworks = 'YKHawkeye/Framework/*.framework'
    end

  # STRouter
  spec.subspec 'STRouter' do |ss|
      ss.source_files = 'STComponentTools/STRouter/**/*.{h,m,mm,c,cpp,swift}'
      ss.public_header_files = 'STComponentTools/STRouter/Public/**/*.h' #此处放置组件的对外暴漏的头文件
#       ss.pod_target_xcconfig = {
#         'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YKHawkeyeWithLoad'
#       }
      ss.dependency 'STComponentTools/STAnnotation'
      ss.dependency 'YYModel'

#       ss.vendored_frameworks = 'YKHawkeye/Framework/*.framework'
    end
  
  # STModuleService
  spec.subspec 'STModuleService' do |ss|
      ss.source_files = 'STComponentTools/STModuleService/**/*.{h,m,mm,c,cpp,swift}'
      ss.public_header_files = 'STComponentTools/STModuleService/Public/**/*.h' #此处放置组件的对外暴漏的头文件
#       ss.pod_target_xcconfig = {
#         'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YKHawkeyeWithLoad'
#       }
      ss.dependency 'STComponentTools/STAnnotation'
#       ss.vendored_frameworks = 'YKHawkeye/Framework/*.framework'
    end

end
