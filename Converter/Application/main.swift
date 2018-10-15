
import UIKit

// For unit testing without interface I change main.swift
let appDelegateClass: AnyClass = NSClassFromString("ConverterTests.TestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
