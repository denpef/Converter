//
//  TickersViewController.swift
//  GithubTickersSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import XLPagerTabStrip
import SnapKit

class TickersViewController: UIViewController, IndicatorInfoProvider {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let disposeBag = DisposeBag()

    var viewModel: TickersViewModel!

    private var itemInfo: IndicatorInfo = "Котировки"

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        tableView.register(TickerTableViewCell.self, forCellReuseIdentifier: "TickerTableViewCell")
        return tableView
    }()

    private lazy var errorBinding = Binder<Error>(self) { (vc, error) in

        debugPrint(error)

        let alert = UIAlertController(title: "Ошибка соединения",
                                      message: "Пожалуйста, повторите попытку позднее",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК",
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)

    }

    override func viewDidLoad() {

        super.viewDidLoad()

        configureUI()
        bindViewModel()

    }

    private func configureUI() {

        navigationController?.navigationBar.barStyle = .blackTranslucent

        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view)
        }

        configureTableView()
    }

    private func configureTableView() {

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

    }

    private func bindViewModel() {

        assert(viewModel != nil)

        tableView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                self.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        let viewWillAppear = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()

        let noteBecomeActive = NotificationCenter
            .default.rx
            .notification(NSNotification.Name.NSExtensionHostDidBecomeActive)
            .mapToVoid()

        let willEnterForeground = NotificationCenter
            .default.rx
            .notification(NSNotification.Name.NSExtensionHostWillEnterForeground)
            .mapToVoid()

        let viewWillDisappear = rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .mapToVoid()

        let WillResignActive = NotificationCenter.default.rx
            .notification(NSNotification.Name.NSExtensionHostWillResignActive)
            .mapToVoid()

        let DidEnterBackground = NotificationCenter.default.rx
            .notification(NSNotification.Name.NSExtensionHostDidEnterBackground)
            .mapToVoid()

        let modelSelected = PublishSubject<TickerItemViewModel?>()

        tableView.rx
            .modelSelected(TickerItemViewModel.self)
            .bind(to: modelSelected)
            .disposed(by: disposeBag)

        let selected = Observable<TickerItemViewModel?>.merge(Observable.just(nil), modelSelected.asObservable())

        let input = TickersViewModel.Input(
            pollingStart: Observable.merge(viewWillAppear, noteBecomeActive, willEnterForeground),
            pollingStop: Observable.merge(viewWillDisappear, WillResignActive, DidEnterBackground),
            selection: selected)

        let output = viewModel.transform(input: input)

        //Bind tickers to UITableView
//        output.tickers.drive(tableView.rx.items(cellIdentifier: TickerTableViewCell.reuseID, cellType: TickerTableViewCell.self)) { tv, viewModel, cell in
//            if viewModel.ticker.quote?.highestBid != cell.viewModel?.ticker.quote?.highestBid {
//
//                cell.bind(viewModel)
//            }
//            }.disposed(by: disposeBag)
//
        let dataSource = RxTableViewSectionedAnimatedDataSource<TickersItemSection>(configureCell: {(_, tableView, indexPath, viewModel) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: TickerTableViewCell.reuseID, for: indexPath) as! TickerTableViewCell
            cell.viewModel = viewModel
            return cell
        })

        output.tickers.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

//        tableView.rx.modelSelected(TickerItemViewModel.self)
//            .asDriver().drive(onNext: { model in
//                guard let strongSelf = self else { return }
//                strongSelf.scrollToTop()
//                guard
//                    let index = output.tickers.firstIndex(where: { $0.title == selectedRate.title }),
//                    index != 0
//                    else { return }
//                rates.remove(at: index)
//                rates.insert(selectedRate, at: 0)
//                mainStore.dispatch(action: PresentableAction(viewState: .success(rates)))
//
//                (strongSelf.tableView.cellForRow(at: indexPath) as? TickerTableViewCell).map { cell in
//                    cell.amountField.isUserInteractionEnabled = true
//                    cell.amountField.becomeFirstResponder()
//                    //cell.amountField.toggleColors()
//                }
//            })

//        output.selectedTicker
//            .drive()
//            .disposed(by: disposeBag)

        output.error
            .drive(errorBinding)
            .disposed(by: disposeBag)

        output.pollingTumbler
            .drive()
            .disposed(by: disposeBag)

    }

    func scrollToTop() {
        tableView.scrollToRow(at: .init(item: 0, section: 0), at: .top, animated: true)
    }

    // MARK: - PagerTabStrip

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}

extension TickersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
