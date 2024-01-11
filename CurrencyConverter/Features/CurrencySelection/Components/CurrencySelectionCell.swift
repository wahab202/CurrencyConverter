//
//  CurrencySelectionCell.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class CurrencySelectionCell: UICollectionViewCell {
    
    private var currencyLabel: UILabel!
    private var currencyNameLabel: UILabel!
    private var flagLabel: UILabel!
    
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
        currencyNameLabel.text = nil
        flagLabel.text = nil
    }
    
    private func setup() {
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        flagLabel = UILabel()
        container.addArrangedSubview(flagLabel)
        
        currencyLabel = UILabel()
        currencyLabel.font = .systemFont(ofSize: 20)
        currencyLabel.textColor = .gray
        currencyLabel.numberOfLines = 1
        container.addArrangedSubview(currencyLabel)
        
        container.addArrangedSubview(UIView())
                
        currencyNameLabel = UILabel()
        container.addArrangedSubview(currencyNameLabel)
    }
    
    func bind(model: CurrencyCellModel) -> Self {
        currencyLabel.text = model.currency
        currencyNameLabel.text = model.currencyName
        flagLabel.text = model.flag

        return self
    }
}

