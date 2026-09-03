require 'xcodeproj'

name = 'unimoduleProbe'
project_path = 'Probe.xcodeproj'

File.write('dummy.swift', "import Foundation\npublic func probeDummy() {}\n")
File.write('probe.m', <<~OBJC)
  #import <Foundation/Foundation.h>

  // Ad-hoc declarations mirroring the exact symbols the UTS plugin bridge uses
  @interface BNaviService : NSObject
  + (instancetype)getInstance;
  @end
  @interface BNaviModel : NSObject
  + (instancetype)getInstance;
  @end
  @interface BNPosition : NSObject
  @end
  @interface BNRoutePlanNode : NSObject
  @end
  @interface BMKMapManager : NSObject
  + (NSString *)getCUID;
  @end

  extern NSString * _Nonnull BNaviTripTypeKey;
  extern NSString * _Nonnull BNaviUI_Enter_AnimationKey;
  extern NSString * _Nonnull BNaviUI_Exit_AnimationKey;
  extern NSString * _Nonnull BNaviUI_Navi_HideDeclarationKey;
  extern NSString * _Nonnull BNaviUI_NormalNavi_TypeKey;

  void probeSymbols(void) {
    (void)[BNaviService getInstance];
    (void)[BNaviModel getInstance];
    (void)[BNPosition new];
    (void)[BNRoutePlanNode new];
    (void)[BMKMapManager getCUID];
    (void)BNaviTripTypeKey;
    (void)BNaviUI_Enter_AnimationKey;
    (void)BNaviUI_Exit_AnimationKey;
    (void)BNaviUI_Navi_HideDeclarationKey;
    (void)BNaviUI_NormalNavi_TypeKey;
  }
OBJC

project = Xcodeproj::Project.new(project_path)
project.root_object.attributes['LastUpgradeCheck'] = '1500'

main_group = project.main_group
group = main_group.new_group('Probe', 'Probe')
file_ref = group.new_file('dummy.swift')
probe_ref = group.new_file('probe.m')

target = project.new_target(:framework, name, :ios, '14.0')
target.add_file_references([file_ref, probe_ref])

target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.probe.#{name}"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
end

project.save
puts "project created: #{project_path}"
