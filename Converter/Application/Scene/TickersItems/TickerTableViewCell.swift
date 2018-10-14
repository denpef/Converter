//
//  TickerTableViewCell.swift
//  GithubTickersSerfing
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
    var imageHeight: CGFloat = 40
    var cellMinWidth: CGFloat = 40
    var generalOffset: CGFloat = 6
    var selectedColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var normalColor = UIColor.lightGray.withAlphaComponent(0.6)
    var countryTitleLabelFont = UIFont.boldSystemFont(ofSize: 16)
    var descriptionLabelFont = UIFont.boldSystemFont(ofSize: 12)
}

final class TickerTableViewCell: UITableViewCell {

    private let showcase = Showcase()

    private lazy var countryImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.layer.cornerRadius = showcase.imageHeight / 2
        view.layer.masksToBounds = true
        //self.countryImageView.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        contentView.addSubview(view)
        return view
    }()

    private lazy var countryTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = showcase.countryTitleLabelFont
        label.textColor = showcase.selectedColor
        contentView.addSubview(label)
        return label
    }()

    private lazy var countrySubtitleLabel: UILabel = {
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

    var viewModel: TickerItemViewModel? {
        didSet {
            bindRx()
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
        countryImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(showcase.generalOffset)
            make.width.height.equalTo(showcase.imageHeight)
        }

        countryTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(countryImageView.snp.right).offset(showcase.generalOffset)
            make.top.equalTo(countryImageView)
        }

        countrySubtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(countryTitleLabel)
            make.top.equalTo(countryTitleLabel.snp.bottom).inset(showcase.generalOffset / 2)
        }

        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(showcase.generalOffset)
            make.width.equalTo(showcase.cellMinWidth).priority(.medium)
            make.left.greaterThanOrEqualTo(countrySubtitleLabel.snp.right).offset(showcase.generalOffset).priority(.high)
            make.centerY.equalToSuperview()
        }

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
            .drive(countryTitleLabel.rx.text)
            .disposed(by: disposeBag!)

        viewModel?.subtitle
            .drive(countrySubtitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.valueString
            .asDriver()
            .drive(onNext: { (value) in
                if self.amountField.isFirstResponder { return }
                self.amountField.text = value
            }).disposed(by: disposeBag)

        viewModel?.countryCode
            .drive(onNext: { (code) in
                guard let code = code else { return }
                if let flag = UIImage.init(flagImageWithCountryCode: code) {
                    self.countryImageView.image = flag
                }
            }).disposed(by: disposeBag)

        amountField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in

                if new.isEmpty { return "" }

                if new.contains(",") {
                    let newCopy = new
                    if newCopy.dropLast(3).contains(",") { return previous ?? "" }
                }

                let separateOverflow = new.filter { $0 == ","}.count > 1
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
                print("[.editingDidEnd, .editingDidEndOnExit]")
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
//        stackView.addArrangedSubview(tickerTitleLaber)
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
//        stackView.addArrangedSubview(tickerSubitleLaber)
//        stackView.addArrangedSubview(percentChangeLabel)
//        contentView.addSubview(stackView)
//
//        return stackView
//    }()
//
//    lazy var tickerTitleLaber: UILabel = {
//        let tickerTitleLaber = UILabel()
//        tickerTitleLaber.textColor = UIColor.black
//        tickerTitleLaber.font = .boldSystemFont(ofSize: 16.0)
//        tickerTitleLaber.textAlignment = .left
//        return tickerTitleLaber
//    }()
//
//    lazy var tickerSubitleLaber: UILabel = {
//        let tickerSubitleLaber = UILabel()
//        tickerSubitleLaber.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        tickerSubitleLaber.font = .systemFont(ofSize: 16)
//        tickerSubitleLaber.textAlignment = .left
//        return tickerSubitleLaber
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
//    func bind(_ viewModel: TickerItemViewModel) {
//
//        self.viewModel = viewModel
//
//        self.tickerTitleLaber.text = viewModel.title.replacingOccurrences(of: "_", with: "/")
//        self.tickerSubitleLaber.text = "Poloniex"
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
