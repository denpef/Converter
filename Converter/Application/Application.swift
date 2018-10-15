//
//  Application.swift
//  Rate
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit

final class Application {

    static let shared = Application()

    private let networkUseCaseProvider: UseCaseProvider

    private init() {
        self.networkUseCaseProvider = NetworkUseCaseProvider()
    }

    func configureMainInterface(in window: UIWindow) {

        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let networkNavigationController = UINavigationController()

        let networkNavigator = DefaultRatesNavigator(
            services: networkUseCaseProvider,
            navigationController: networkNavigationController)

//        let tabBarController = UITabBarController()

//
//        tabBarController.viewControllers = [
//            EmptyViewController(),
//            networkNavigationController
//        ]
//
        //window.rootViewController = tabBarController
        window.rootViewController = networkNavigationController

        networkNavigator.toRates()

    }
}
