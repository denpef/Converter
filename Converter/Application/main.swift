
import UIKit

let appDelegateClass: AnyClass = NSClassFromString("ConverterTests.TestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
