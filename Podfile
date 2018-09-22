source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

inhibit_all_warnings!

def common_pods
    pod 'RxCocoa'
end

target :MVVM do
    common_pods
end

target :MVVMTests do
    common_pods
    pod 'SwiftLint'
    pod 'RxTest'
end