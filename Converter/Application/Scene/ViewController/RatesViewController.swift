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

    private var itemInfo: IndicatorInfo = "Котировки"

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: "RateTableViewCell")
        return tableView
    }()

//    private lazy var controlProperty: (Observable<String?>) -> Void = { [ratesView, disposeBag] property in
//
//        property
//            .debounce(0.5, scheduler: ConcurrentMainScheduler.instance)
//            .map { $0 ?? "" }
//            .distinctUntilChanged()
//            .filter { !$0.isEmpty }
//            .bind(onNext: { self.actions.changeValue(rate, $0) })
//            .disposed(by: disposeBag)
//    }

    
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

//    @objc func didChange(notification: NSNotification) {
//        guard let textfield = notification.object as? UITextField else { return }
//        //guard textfield != hiddenTextfield else { return }
//
//        var text = textfield.text
//        if text == "" {
//            text = nil
//        }
//
//        self.viewModel?.set
//    }
    
//    textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
//    .asObservable()
//    .subscribe(onNext: { _ in
//    print("editing state changed")
//    })
//    .disposed(by: disposeBag)
    
    @objc func didChange(notification: NSNotification) {
        guard let textfield = notification.object as? UITextField else { return }

        var text = textfield.text
        if text == "" {
            text = nil
        }

        self.viewModel.baseAmt.value = text
    }
    
    private func bindViewModel() {
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(RatesViewController.didChange(notification:)),
                name: UITextField.textDidChangeNotification, object: nil)

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

        let modelSelected = PublishSubject<RateCellViewModel?>()

        tableView.rx
            .modelSelected(RateCellViewModel.self)
            .bind(to: modelSelected)
            .disposed(by: disposeBag)

        let selected = Observable<RateCellViewModel?>.merge(Observable.just(nil), modelSelected.asObservable())

        let input = RatesViewModel.Input(
            pollingStart: Observable.merge(viewWillAppear, noteBecomeActive, willEnterForeground),
            pollingStop: Observable.merge(viewWillDisappear, WillResignActive, DidEnterBackground),
            selection: selected)

        let output = viewModel.transform(input: input)

        //Bind rates to UITableView
//        output.rates.drive(tableView.rx.items(cellIdentifier: RateTableViewCell.reuseID, cellType: RateTableViewCell.self)) { tv, viewModel, cell in
//            if viewModel.rate.quote?.highestBid != cell.viewModel?.rate.quote?.highestBid {
//
//                cell.bind(viewModel)
//            }
//            }.disposed(by: disposeBag)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(RatesViewController.didChange(notification:)), name: UITextField.textDidChangeNotification, object: nil)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<RatesItemSection>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .none,
                reloadAnimation: .none,
                deleteAnimation: .none
            ),
            configureCell: {(_, tableView, indexPath, viewModel) -> UITableViewCell in
                tableView.register(RateTableViewCell.self, forCellReuseIdentifier: RateTableViewCell.reuseID)
                let cell = tableView.dequeueReusableCell(withIdentifier: RateTableViewCell.reuseID, for: indexPath) as! RateTableViewCell
                cell.viewModel = viewModel
//                cell.amountField.rx
//                    .controlEvent(.editingChanged)
//                    .debounce(0.5, scheduler: MainScheduler.instance)
//                    .flatMap { cell.amountField.rx.text }
//                    //.debug("\(cell.viewModel?.rate.title)", trimOutput: false)
//                    .bind(to:self.viewModel.baseAmt )
                
                return cell
            })

        output.rates.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

//        output.rates
//            .drive(tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(RateCellViewModel.self)
            ).bind { [unowned self] indexPath, rateItemViewModel in
                //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7, execute: {
                    //self.tableView.deselectRow(at: indexPath, animated: true)
                    self.scrollToTop()
                    self.changeBaseCurrency(to: rateItemViewModel.rate.title)
                    //self.moveModel(rateItemViewModel, toTopOf: output.rates)
                    //actions.select(rate)
                    (self.tableView.cellForRow(at: indexPath) as? RateTableViewCell).map { cell in
                        cell.amountField.isUserInteractionEnabled = true
                        cell.amountField.becomeFirstResponder()
                        //cell.amountField.toggleColors()
                    }
                //})
            }.disposed(by: disposeBag)
        
//        tableView.rx.modelSelected(RateItemViewModel.self)
//            .asDriver().drive(onNext: { model in
//                guard let strongSelf = self else { return }
//                strongSelf.scrollToTop()
//                guard
//                    let index = output.rates.firstIndex(where: { $0.title == selectedRate.title }),
//                    index != 0
//                    else { return }
//                rates.remove(at: index)
//                rates.insert(selectedRate, at: 0)
//                mainStore.dispatch(action: PresentableAction(viewState: .success(rates)))
//
//                (strongSelf.tableView.cellForRow(at: indexPath) as? RateTableViewCell).map { cell in
//                    cell.amountField.isUserInteractionEnabled = true
//                    cell.amountField.becomeFirstResponder()
//                    //cell.amountField.toggleColors()
//                }
//            })

//        output.selectedRate
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
    
//    private func moveModel(_ rateModel: RateCellViewModel, toTopOf collection: Driver<[RatesItemSection]>) {
//        if let index = collection.value[0].items.index(where: { (model) -> Bool in
//            model == rateModel
//        }) {
//            let newBase = collection.value[0].items.remove(at: index)
//            collection.value[0].items.insert(newBase, at: 0)
//        }
//    }
    
//    private func configure(_ cell: RateTableViewCell, with rate: Rate) {
//        cell.configure(with: rate)
//
////        cell.amountField.rx
////            .controlEvent(.editingDidEnd)
////            .bind { cell.amountField.toggleColors() }
////            .disposed(by: disposeBag)
//
//        cell.amountField.rx
//            .controlEvent(.editingChanged)
//            .flatMap { cell.amountField.rx.text }
//            .bind(to: { controlProperty(rate, $0) })
//    }
    
}

extension RatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
