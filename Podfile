# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

abstract_target 'ConverterApp' do
    use_frameworks!
    
    target 'Converter' do
        pod 'RxSwift', '~> 4.0'
        pod 'RxCocoa', '~> 4.0'
        pod 'RxDataSources'
        pod 'XLPagerTabStrip', :git => 'https://github.com/xmartlabs/XLPagerTabStrip', :branch => 'master'
        pod 'SnapKit'
        pod 'Moya/RxSwift', '~> 11.0'
        pod 'RealmSwift', '~> 3.8'
        pod 'RxRealm', '~> 0.7.5'
        pod 'FlagKit', '~> 2.0'
    end
    
    target 'ConverterTests' do
        pod 'RxSwift', '~> 4.0'
        pod 'RxCocoa', '~> 4.0'
        pod 'RxTest', '~> 4.0'
        pod 'Moya/RxSwift', '~> 11.0'
        pod 'RealmSwift', '~> 3.8'
        pod 'Quick'
        pod 'Nimble'
    end
    
end
