//
//  ConvertedCurrencyCell.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ConvertedCurrencyCell: UICollectionViewCell {
    
    private var currencyLabel: UILabel!
    private var covertedAmountLabel: UILabel!
    private var countryLabel: UILabel!
    
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currencyLabel.text = nil
        covertedAmountLabel.text = nil
        countryLabel.text = nil
    }
    
    private func setup() {
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        container.addArrangedSubview(UIView())
        
        countryLabel = UILabel()
        container.addArrangedSubview(countryLabel)
        
        currencyLabel = UILabel()
        currencyLabel.font = .systemFont(ofSize: 20)
        currencyLabel.textColor = .gray
        currencyLabel.numberOfLines = 1
        container.addArrangedSubview(currencyLabel)
        
        covertedAmountLabel = UILabel()
        covertedAmountLabel.font = .systemFont(ofSize: 16)
        covertedAmountLabel.textColor = .label
        covertedAmountLabel.numberOfLines = 1
        container.addArrangedSubview(covertedAmountLabel)
        
    }
    
    func bind(model: ConvertedCurrencyModel) -> Self {
        currencyLabel.text = model.currency
        covertedAmountLabel.text = formatAmount(amount: model.amount)
        countryLabel.text = model.country

        return self
    }
    
    func formatAmount(amount: Double) -> String? {
        let million: Double = 1000000
        let billion: Double = 1000000000
        
        if amount >= billion {
            let formattedNumber = amount / billion
            return String(format: "%.2fB", formattedNumber)
        } else if amount >= million {
            let formattedNumber = amount / million
            return String(format: "%.2fM", formattedNumber)
        } else {
            return numberFormatter.string(from: NSNumber(value: amount))
        }
    }
}

