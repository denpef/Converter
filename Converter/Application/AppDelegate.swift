//
//  AppDelegate.swift
//  Converter
//
//  Created by Денис Ефимов on 10.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = ButtonBarExampleViewController()
        window.makeKeyAndVisible()

        self.window = window

        return true

    }
}
