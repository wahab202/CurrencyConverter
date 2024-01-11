//
//  CurrencySelectionControl.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import UIKit
import RxCocoa
import RxSwift

final class CurrencySelectionControl: UIControl, Fadable {
    
    var country: String? = "🇺🇸" {
        didSet {
            countryLabel.text = country
        }
    }
    
    var currency: String = "USD" {
        didSet {
            currencyLabel.text = currency
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateState()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }
    
    private var countryLabel: UILabel!
    private var currencyLabel: UILabel!
    private var arrowButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        countryLabel = UILabel()
        stackView.addArrangedSubview(countryLabel)
        
        currencyLabel = UILabel()
        stackView.addArrangedSubview(currencyLabel)
        
        arrowButton = UIButton()
        arrowButton.imageView?.contentMode = .scaleAspectFit
        arrowButton.setImage(UIImage(named: "selectionIcon"), for: .normal)
        arrowButton.tintColor = .gray
        arrowButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        stackView.addArrangedSubview(arrowButton)
    }
    
    var tap: Signal<()> {
        arrowButton.rx.tap.asSignal()
    }
    
    private func updateState() {
        let isActive = isHighlighted || isSelected
        
        isActive ? fadeIn() : fadeOut()
    }
    
    @objc func buttonTapped() {
            print("Hello")
        }
}
