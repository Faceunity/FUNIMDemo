platform :ios, '8.0'
workspace 'NIM.xcworkspace'

abstract_target 'NIMDemo' do
    pod 'SDWebImage', '~> 4.2.2'
    pod 'Toast', '~> 3.0'
    pod 'M80AttributedLabel', '~> 1.6.3'
    pod 'TZImagePickerController', '~> 1.9.3'

    target 'NIM' do
        project 'NIM.xcodeproj'
        pod 'FMDB', '~> 2.7.2'
        pod 'Reachability', '~> 3.2'
        pod 'CocoaLumberjack', '~> 3.2.1'
        pod 'SSZipArchive', '~> 1.8.1'
        pod 'SVProgressHUD', '~> 2.1.2'
        pod 'Fabric'
        pod 'Crashlytics'
    end
    
    target 'NIMKit' do
        project '../NIMKit/NIMKit.xcodeproj'
    end
end

