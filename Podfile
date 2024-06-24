# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source "https://github.com/CocoaPods/Specs.git"
#source "https://github.com/zoloz-pte-ltd/zoloz-demo-ios"
install! 'cocoapods', :disable_input_output_paths => true
use_modular_headers!

#source "http://gitlab.wuu.space:30000/Lee/hjafnetworkingmanagerlib.git"
target 'DXPNetWorkingManagerLib' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!


  pod 'DXPToolsLib'
  pod 'AFNetworking', '~> 4.0.1'

	
post_install do |installer|
		installer.aggregate_targets.each do |target|
			target.xcconfigs.each do |variant, xcconfig|
				xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
				IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
			end
		end
		installer.pods_project.targets.each do |target|
			target.build_configurations.each do |config|
			config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

				if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
					xcconfig_path = config.base_configuration_reference.real_path
					IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
				end
			end
		end
	end
end
