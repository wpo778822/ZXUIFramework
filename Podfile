post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end
platform :ios, '8.0'
inhibit_all_warnings!

target 'ZXUI' do
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'YYWebImage'
    pod 'MBProgressHUD'
    # 高德
    pod 'AMapLocation'
    pod 'AMap2DMap' 
    pod 'AMapSearch'
end
