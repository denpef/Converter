//
//  RateTableViewCell.swift
//  GithubRatesSerfing
//
//  Created by Денис Ефимов on 02.10.2018.
//  Copyright © 2018 Denis Efimov. All rights reserved.
//

import UIKit
import SnapKit
import FlagKit
import RxSwift
import RxCocoa

struct Showcase {
    let standartHeight: CGFloat = 40
    let cellMinWidth: CGFloat = 40
    let generalOffset: CGFloat = 6
    let selectedColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let normalColor = UIColor.lightGray.withAlphaComponent(0.6)
    let countryTitleLabelFont = UIFont.boldSystemFont(ofSize: 16)
    let descriptionLabelFont = UIFont.boldSystemFont(ofSize: 12)
    var labelsOffset: CGFloat {
        get {
            return self.standartHeight + 2 * self.generalOffset
        }
    }
}

final class RateTableViewCell: UITableViewCell {

    private let showcase = Showcase()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.contentMode = .center
        
        stackView.addArrangedSubview(tickerLabel)
        stackView.addArrangedSubview(fullNameLabel)
        contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var flagImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        contentView.addSubview(view)
        return view
    }()

    private lazy var tickerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = showcase.countryTitleLabelFont
        label.textColor = showcase.selectedColor
        contentView.addSubview(label)
        return label
    }()

    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = showcase.descriptionLabelFont
        label.textColor = showcase.normalColor
        contentView.addSubview(label)
        return label
    }()

    private(set) lazy var amountField: UITextField = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.textAlignment = .right
        field.isUserInteractionEnabled = false
        contentView.addSubview(field)
        return field
    }()

    private lazy var underlinView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        contentView.addSubview(view)
        return view
    }()

//    override func prepareForReuse() {
//        amountField.isUserInteractionEnabled = false
//    }
    
//    func configure(with model: Rate) {
//
//        selectionStyle = .none
//        let modelTitle = model.title
//
//        // Flag
//        if let flag = Flag(countryCode: modelTitle) {
//            self.flagImageView.image = flag.image(style: .circle)
//        }
//
//        // Ticker
//        tickerLabel.text = model.title
//
//        // Country description
//        fullNameLabel.text = NSLocale.current.localizedString(forCurrencyCode: model.title)
//
//        // Amount
//        //amountField.text = String(format: "%.2f", model.ratio)
//        amountField.sizeToFit()
//    }
    
    var viewModel: RateCellViewModel? {
        didSet {
            bindRx()
            //configure(with: viewModel!.rate)
        }
    }

    var disposeBag: DisposeBag!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.disposeBag = DisposeBag()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        self.disposeBag = DisposeBag()
        super.init(coder: aDecoder)
    }

    private func setupUI() {
        
        selectionStyle = .none
        
        flagImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(showcase.generalOffset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(showcase.standartHeight)
        }

        titleStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(showcase.labelsOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(showcase.standartHeight)
        }
        
        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(showcase.generalOffset)
            make.width.greaterThanOrEqualTo(showcase.cellMinWidth).priority(.medium)
            make.left.greaterThanOrEqualTo(fullNameLabel.snp.right).offset(showcase.generalOffset).priority(.high)
            make.centerY.equalToSuperview()
        }
        amountField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        underlinView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(showcase.generalOffset)
            make.width.equalTo(amountField.snp.width)
            make.height.equalTo(2)
            make.left.equalTo(amountField.snp.left)
            make.top.equalTo(amountField.snp.bottom).inset(-3)
        }
        
    }
    
    func bindRx() {

        viewModel?.title
            .drive(tickerLabel.rx.text)
            .disposed(by: disposeBag!)

        viewModel?.description
            .drive(fullNameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.total
            .asDriver()
            .drive(onNext: { (value) in
                if self.amountField.isFirstResponder { return }
                self.amountField.text = value
//                print(Thread.current)
//                debugPrint("\(self.viewModel?.rate.title) = \(self.amountField.text)")
            }).disposed(by: disposeBag)
//
        viewModel?.title
            .drive(onNext: { (code) in
                if let flag = Flag(countryCode: code) {
                    self.flagImageView.image = flag.image(style: .circle)
                }
            }).disposed(by: disposeBag!)
        
        amountField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in

                if new.isEmpty { return "" }

                if new.contains(".") {
                    let newCopy = new
                    if newCopy.dropLast(3).contains(".") { return previous ?? "" }
                }

                let separateOverflow = new.filter { $0 == "."}.count > 1
                if !new.isDigits || separateOverflow {
                    return previous ?? ""
                } else {
                    return new
                }

            }
            .subscribe(amountField.rx.text)
            .disposed(by: disposeBag)

        amountField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] (_) in
                self.underlinView.backgroundColor = .lightGray
            }).disposed(by: disposeBag)

        amountField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [unowned self] (_) in
                self.underlinView.backgroundColor = .blue
            }).disposed(by: disposeBag)
    }
}

//    lazy var titleStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.spacing = 10
//        stackView.axis = .horizontal
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//        stackView.contentMode = .scaleToFill
//
//        stackView.addArrangedSubview(rateTitleLaber)
//        stackView.addArrangedSubview(highestBidLabel)
//        contentView.addSubview(stackView)
//        return stackView
//    }()
//
//    lazy var subtitleStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.spacing = 10
//        stackView.axis = .horizontal
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//        stackView.contentMode = .scaleToFill
//
//        stackView.addArrangedSubview(rateSubitleLaber)
//        stackView.addArrangedSubview(percentChangeLabel)
//        contentView.addSubview(stackView)
//
//        return stackView
//    }()
//
//    lazy var rateTitleLaber: UILabel = {
//        let rateTitleLaber = UILabel()
//        rateTitleLaber.textColor = UIColor.black
//        rateTitleLaber.font = .boldSystemFont(ofSize: 16.0)
//        rateTitleLaber.textAlignment = .left
//        return rateTitleLaber
//    }()
//
//    lazy var rateSubitleLaber: UILabel = {
//        let rateSubitleLaber = UILabel()
//        rateSubitleLaber.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        rateSubitleLaber.font = .systemFont(ofSize: 16)
//        rateSubitleLaber.textAlignment = .left
//        return rateSubitleLaber
//    }()
//
//    lazy var percentChangeLabel: UILabel = {
//        let percentChangeLabel = UILabel()
//        percentChangeLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        percentChangeLabel.font = .systemFont(ofSize: 16.0)
//        percentChangeLabel.textAlignment = .right
//        percentChangeLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: NSLayoutConstraint.Axis.horizontal)
//        return percentChangeLabel
//    }()
//
//    lazy var highestBidLabel: UILabel = {
//        let highestBid = UILabel()
//        highestBid.textColor = .black
//        highestBid.font = .boldSystemFont(ofSize: 16.0)
//        highestBid.textAlignment = .right
//        highestBid.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: NSLayoutConstraint.Axis.horizontal)
//        return highestBid
//    }()
//
//    var justCreated: Bool = true
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//        justCreated = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func makeConstraints() {
//
//        titleStackView.snp.makeConstraints { maker in
//            maker.top.equalTo(6)
//            maker.left.equalTo(20)
//            maker.right.equalTo(-20)
//            maker.height.equalTo(21)
//        }
//
//        subtitleStackView.snp.makeConstraints { maker in
//            maker.top.equalTo(32)
//            maker.left.equalTo(20)
//            maker.right.equalTo(-20)
//            maker.height.equalTo(21)
//        }
//
//    }
//
//    func setupUI() {
//
//        makeConstraints()
//
//    }
//
//    func bind(_ viewModel: RateItemViewModel) {
//
//        self.viewModel = viewModel
//
//        self.rateTitleLaber.text = viewModel.title.replacingOccurrences(of: "_", with: "/")
//        self.rateSubitleLaber.text = "Poloniex"
//
//        let endpointHighestBid = viewModel.highestBid ?? "--"
//        let endpointPercentChange = viewModel.percentChange ?? "--"
//
//        if let percentChange = Double(endpointPercentChange) {
//            let labelColor = percentChange > 0 ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
//            percentChangeLabel.textColor = labelColor
//        }
//
//        let basictHighestBid = self.highestBidLabel.text ?? ""
//        let basicPercentChange = self.percentChangeLabel.text ?? ""
//
//        if endpointHighestBid != basictHighestBid
//            || endpointPercentChange != basicPercentChange {
//            if justCreated {
//                setIndicators(highestBid: endpointHighestBid, percentChange: endpointPercentChange)
//                justCreated = false
//            } else {
//                animateLabels(highestBid: endpointHighestBid, percentChange: endpointPercentChange)
//            }
//        }
//    }
//
//    private func setAlpha(value: CGFloat) {
//        self.highestBidLabel.alpha = value
//        self.percentChangeLabel.alpha = value
//    }
//
//    private func setIndicators(highestBid: String?, percentChange: String?) {
//        self.highestBidLabel.text = highestBid
//        self.percentChangeLabel.text = percentChange
//    }
//
//    private func animateLabels(highestBid: String?, percentChange: String?) {
//        setAlpha(value: 0.0)
//        UIView.animate(withDuration: 0.3) {
//            self.highestBidLabel.text = highestBid
//            self.percentChangeLabel.text = percentChange
//            self.highestBidLabel.alpha = 1
//            self.percentChangeLabel.alpha = 1
//        }
//    }
