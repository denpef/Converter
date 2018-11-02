//
//  RatesViewController.swift
//  GithubRatesSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources
import XLPagerTabStrip
import SnapKit

class RatesViewController: UIViewController, IndicatorInfoProvider {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let disposeBag = DisposeBag()

    var viewModel: RatesViewModel!

    // XLPagerTabStrip
    private var itemInfo: IndicatorInfo = "Котировки"

    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        self.view.addSubview(tableView)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: "RateTableViewCell")
        
        return tableView
        
    }()
    
    private lazy var errorBinding = Binder<Error>(self) { (vc, error) in

        debugPrint("errorBinding: \(error)")

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

        let cellReuseIdentifier = String(describing: RateTableViewCell.self)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view)
        }

        configureTableView()
    }

    private func configureTableView() {

        tableView.delegate = self
//        tableView.rx
//            .setDelegate(self)
//            .disposed(by: disposeBag)

    }
    
    @objc func didChange(notification: NSNotification) {
        
        guard let textField = notification.object as? UITextField else { return }
        
        var text = textField.text
        if text == "" {
            text = nil
        }
        
        self.viewModel.baseAmt.accept(text)
    }
    
    private func bindViewModel() {
        
        assert(viewModel != nil)

        NotificationCenter.default.addObserver(self, selector: #selector(RatesViewController.didChange(notification:)), name: UITextField.textDidChangeNotification, object: nil)
        
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

        let willResignActive = NotificationCenter.default.rx
            .notification(NSNotification.Name.NSExtensionHostWillResignActive)
            .mapToVoid()

        let didEnterBackground = NotificationCenter.default.rx
            .notification(NSNotification.Name.NSExtensionHostDidEnterBackground)
            .mapToVoid()

        let modelSelected = PublishSubject<RateCellViewModel?>()

        tableView.rx
            .modelSelected(RateCellViewModel.self)
            .bind(to: modelSelected)
            .disposed(by: disposeBag)

        let selected = Observable<RateCellViewModel?>.merge(Observable.just(nil), modelSelected.asObservable())

        //let baseAmt = BehaviorRelay<String?>(value: "1")
        let scheduler = ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated))
        
        let input = RatesViewModel.Input(
//            pollingStart: Observable.merge(viewWillAppear, noteBecomeActive, willEnterForeground),
//            pollingStop: Observable.merge(viewWillDisappear, WillResignActive, DidEnterBackground),
            selection: selected,
            scheduler: scheduler)//,
            //baseAmt: baseAmt)

        let output = viewModel.transform(input: input)

        Observable.merge(viewWillAppear, noteBecomeActive, willEnterForeground)
            .flatMapLatest {
                Observable.just(true)
            }.bind(to: output.polling)
            .disposed(by: disposeBag)
        
        Observable.merge(viewWillDisappear, willResignActive, didEnterBackground)
            .flatMapLatest {
                Observable.just(false)
            }.bind(to: output.polling)
            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<RatesItemSection>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .none,
                reloadAnimation: .none,
                deleteAnimation: .none
            ),
            configureCell: {(_, tableView, indexPath, viewModel) -> UITableViewCell in
                let cellReuseIdentifier = String(describing: RateTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! RateTableViewCell
                cell.viewModel = viewModel
//                cell.amountField.rx.text
//                    .changed
//                    .bind(to: baseAmt)
//                    .disposed(by: cell.disposeBag)
                return cell
            })

        output.rates.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(RateCellViewModel.self)
            ).bind { [unowned self] indexPath, rateItemViewModel in
                    self.scrollToTop()
                    self.changeBaseCurrency(to: rateItemViewModel.rate.title)
                    let cell = self.tableView.cellForRow(at: indexPath) as? RateTableViewCell
                    cell?.amountField.isUserInteractionEnabled = true
                    cell?.amountField.becomeFirstResponder()
//                    (self.tableView.cellForRow(at: indexPath) as? RateTableViewCell).map { cell in
//                        cell.amountField.isUserInteractionEnabled = true
//                        cell.amountField.becomeFirstResponder()
//                    }
            }.disposed(by: disposeBag)

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

    private func changeBaseCurrency(to currency: String) {
        guard let realm = try? Realm() else { return }
        do {
            guard let object = realm
                .objects(Rate.self)
                .filter("isBase = true")
                .first else { return }
            if currency == object.title { return }
            try realm.write {
                object.isBase = false
                if let newBase = realm.objects(Rate.self).filter("title LIKE '\(currency)'").first {
                    newBase.isBase = true
                }
            }
        } catch {
            debugPrint("changeBaseCurrency: \(error)")
        }
    }
}

extension RatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
