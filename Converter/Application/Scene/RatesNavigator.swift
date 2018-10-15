//
//  PostsNavigator.swift
//  GithubRatesSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit

protocol RatesNavigator {
    func configureRatesViewController() -> RatesViewController
    func toRates()
}

class DefaultRatesNavigator: RatesNavigator {

    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    func configureRatesViewController() -> RatesViewController {
        let vc = RatesViewController()
        vc.viewModel = RatesViewModel(useCase: services.makeRatesUseCase())
        return vc
    }

    func toRates() {
        let vc = RatesViewController()
        vc.viewModel = RatesViewModel(useCase: services.makeRatesUseCase())
        navigationController.pushViewController(vc, animated: true)
    }

}
