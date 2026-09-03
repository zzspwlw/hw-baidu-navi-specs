require 'xcodeproj'

name = 'unimoduleProbe'
project_path = 'Probe.xcodeproj'

File.write('dummy.swift', "import Foundation\npublic func probeDummy() {}\n")

project = Xcodeproj::Project.new(project_path)
project.root_object.attributes['LastUpgradeCheck'] = '1500'

main_group = project.main_group
group = main_group.new_group('Probe', 'Probe')
file_ref = group.new_file('dummy.swift')

target = project.new_target(:framework, name, :ios, '14.0')
target.add_file_references([file_ref])

target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.probe.#{name}"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
end

project.save
puts "project created: #{project_path}"
