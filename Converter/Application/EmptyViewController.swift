//
//  EmptyViewController.swift
//  Converter
//
//  Created by Денис Ефимов on 04.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit

class EmptyViewController: UIViewController, IndicatorInfoProvider {

    lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.view.addSubview(headerView)
        return headerView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var itemInfo: IndicatorInfo = "ETF"

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {

        headerView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
