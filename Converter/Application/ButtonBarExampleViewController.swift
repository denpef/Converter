//
//  ButtonBarExampleViewController.swift
//  Converter
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit

class ButtonBarExampleViewController: ButtonBarPagerTabStripViewController {

    var isReload = false
    let hatColor = #colorLiteral(red: 0.1333333333, green: 0.1764705882, blue: 0.262745098, alpha: 1)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {

        let frame = self.view.frame
        let layout = UICollectionViewFlowLayout()

        let barView = ButtonBarView(frame: frame, collectionViewLayout: layout)
        let ownContainerView = UIScrollView(frame: frame)

        self.view.translatesAutoresizingMaskIntoConstraints = false
        barView.translatesAutoresizingMaskIntoConstraints = false
        ownContainerView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(barView)
        self.view.addSubview(ownContainerView)

        self.buttonBarView = barView
        self.containerView = ownContainerView

        ownContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(65)
            make.bottom.left.right.equalTo(self.view)
        }

        barView.snp.makeConstraints { (make) in
            make.height.equalTo(65)
            make.top.left.right.equalTo(self.view)
        }

        // change selected bar color
        settings.style.buttonBarBackgroundColor = hatColor
        settings.style.buttonBarItemBackgroundColor = hatColor
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        settings.style.buttonBarItemTitleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.selectedBarVerticalAlignment = .bottom

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            newCell?.label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }

        super.viewDidLoad()
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        // Rate View Controller Setup
        let networkUseCaseProvider: UseCaseProvider = NetworkUseCaseProvider()

        let networkNavigationController = UINavigationController()

        let networkNavigator = DefaultRatesNavigator(
            services: networkUseCaseProvider,
            navigationController: networkNavigationController)

        let childOne = networkNavigator.configureRatesViewController()
        
        // Second controller for example
        let childTwo = EmptyViewController()

        guard isReload else {
            return [childOne, childTwo]
        }

        return [childOne, childTwo]
    }

    override func reloadPagerTabStripView() {
        isReload = true
        super.reloadPagerTabStripView()
    }
}
