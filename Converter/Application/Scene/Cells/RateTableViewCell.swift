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

final class RateTableViewCell: UITableViewCell {

    var viewModel: RateCellViewModel? {
        didSet {
            bindRx()
        }
    }
    
    var disposeBag: DisposeBag!

    struct Showcase {
        
        let height: CGFloat = 40
        let cellWidth: CGFloat = 40
        let offset: CGFloat = 6
        let labelTextSelectedColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let subtitleColor = UIColor.lightGray.withAlphaComponent(0.6)
        let tickerLabelFont = UIFont.boldSystemFont(ofSize: 16)
        let descriptionLabelFont = UIFont.boldSystemFont(ofSize: 12)
        var labelsOffset: CGFloat {
            get {
                return self.height + 2 * self.offset
            }
        }
    }

    private let showcase = Showcase()

    private lazy var titleStackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        //stackView.contentMode = .center
        
        stackView.addArrangedSubview(tickerLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        return stackView
        
    }()
    
    private lazy var flagImageView: UIImageView = {
        let view = UIImageView()
        //view.contentMode = .scaleAspectFill
        view.contentMode = .scaleToFill
        
        return view
        
    }()

    private lazy var tickerLabel: UILabel = {
        
        let label = UILabel()
        
        label.numberOfLines = 1
        label.font = showcase.tickerLabelFont
        label.textColor = showcase.labelTextSelectedColor
        
        return label
        
    }()

    private lazy var descriptionLabel: UILabel = {
        
        let label = UILabel()
        
        label.numberOfLines = 1
        label.font = showcase.descriptionLabelFont
        label.textColor = showcase.subtitleColor
        
        return label
        
    }()

    private(set) lazy var amountField: UITextField = {
        
        let field = UITextField()
        
        field.keyboardType = .decimalPad
        field.textAlignment = .right
        field.isUserInteractionEnabled = false
        
        return field
        
    }()

    private lazy var underlinView: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        return view
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.disposeBag = DisposeBag()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        self.disposeBag = DisposeBag()
        super.init(coder: aDecoder)
    }

    // MARK: - Private methods
    
    private func setupUI() {
        
        selectionStyle = .none
        
        addSubviews()
        makeConstraints()
        
    }
    
    private func addSubviews() {
        
        contentView.addSubview(titleStackView)
        contentView.addSubview(flagImageView)
        contentView.addSubview(amountField)
        contentView.addSubview(underlinView)
        
    }
    
    private func makeConstraints() {
     
        flagImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(showcase.offset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(showcase.height)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(showcase.labelsOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(showcase.height)
        }
        
        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(showcase.offset)
            make.width.greaterThanOrEqualTo(showcase.cellWidth).priority(.medium)
            make.left.greaterThanOrEqualTo(descriptionLabel.snp.right).offset(showcase.offset).priority(.high)
            make.centerY.equalToSuperview()
        }
        amountField.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        underlinView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(showcase.offset)
            make.width.equalTo(amountField.snp.width)
            make.height.equalTo(2)
            make.left.equalTo(amountField.snp.left)
            make.top.equalTo(amountField.snp.bottom).inset(-3)
        }
        
    }
    
    private func bindRx() {

        viewModel?.title
            .drive(tickerLabel.rx.text)
            .disposed(by: disposeBag!)

        viewModel?.description
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel?.total
            .asDriver()
            .drive(onNext: { (value) in
                if self.amountField.isFirstResponder { return }
                self.amountField.text = value
            }).disposed(by: disposeBag)

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
