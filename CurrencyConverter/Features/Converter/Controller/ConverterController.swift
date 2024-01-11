//
//  ConverterController.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ConverterController: UIViewController, ConverterCoordinator {
    
    var root: UIViewController {
        return self
    }
    
    private lazy var cv: UICollectionView = {
        let layout = createLayout()

        let cv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.allowsMultipleSelection = false
        cv.allowsSelection = true
        cv.register(ConvertedCurrencyCell.self, forCellWithReuseIdentifier: "ConvertedCurrencyCell")
        return cv
    }()
    
    private lazy var amountField: UITextField = {
        let amountField = UITextField()
        amountField.placeholder = "Amount"
        amountField.text = "1.0"
        amountField.keyboardType = .decimalPad
        amountField.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [doneButton]
        amountField.inputAccessoryView = toolbar
        return amountField
    }()
    
    private lazy var updatedAtLabel: UILabel = {
        let updatedAtLabel = UILabel()
        updatedAtLabel.font = .systemFont(ofSize: 12)
        updatedAtLabel.isHidden = true
        return updatedAtLabel
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var currencySelectionControl: CurrencySelectionControl = {
       return CurrencySelectionControl()
    }()
    
    private let bag: DisposeBag
    private let vm: ConverterViewModel
    
    init(vm: ConverterViewModel = ConverterViewModel()) {
        self.vm = vm
        self.bag = DisposeBag()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Currency Converter"
        
        view.addSubview(updatedAtLabel)
        updatedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            updatedAtLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            updatedAtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let controlView = UIView()
        controlView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        controlView.layer.cornerRadius = 8
        controlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlView)
        NSLayoutConstraint.activate([
            controlView.topAnchor.constraint(equalTo: updatedAtLabel.bottomAnchor, constant: 6),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            controlView.heightAnchor.constraint(equalToConstant: 40.0)
        ])
        
        let controlStack = UIStackView()
        controlStack.axis = .horizontal
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlView.addSubview(controlStack)
        NSLayoutConstraint.activate([
            controlStack.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 4),
            controlStack.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -4),
            controlStack.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 8),
            controlStack.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -12)
        ])
        
        controlStack.addArrangedSubview(amountField)
        controlStack.addArrangedSubview(currencySelectionControl)

        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 8),
            cv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        let amount = amountField.rx.text
            .map { $0 ?? "0.0" }
            .map { $0.isEmpty ? "0.0" : $0 }
            .asSignal(onErrorSignalWith: .never())
        
        let offsetChanged = cv.rx.contentOffset
            .map { _ in () }
            .asSignal(onErrorSignalWith: .never())
        
        let input = ConverterViewModel.Input(
            amount: amount,
            selectCurrency: currencySelectionControl.tap,
            offsetChanged: offsetChanged
        )

        let output = vm.transform(input: input)

        let dataSource = RxCollectionViewSectionedReloadDataSource<ConverterSection>(
            configureCell: { dataSource, collectionView, indexPath, model in
                let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: "ConvertedCurrencyCell", for: indexPath) as! ConvertedCurrencyCell
                return cell.bind(model: model)
        })
            
        let disposables = [
            output.sections.drive(cv.rx.items(dataSource: dataSource)),
            output.error.drive(errorBinder),
            output.loading.drive(indicator.rx.isAnimating),
            output.country.drive(countryBinder),
            output.currency.drive(currencyBinder),
            output.navigation.drive(navigationBinder),
            output.updatedAt.drive(updatedAtBinder),
            output.offsetChanged.drive(hideKeyboardBinder)
        ]

        disposables.forEach { $0.disposed(by: bag) }
    }
    
    private var hideKeyboardBinder: Binder<()> {
        return Binder(amountField) { field, _ in
            field.resignFirstResponder()
        }
    }
    
    private var currencyBinder: Binder<String> {
        return Binder(currencySelectionControl) { currencySelectionControl, currency in
            currencySelectionControl.currency = currency
        }
    }
    
    private var countryBinder: Binder<String?> {
        return Binder(currencySelectionControl) { currencySelectionControl, country in
            currencySelectionControl.country = country
        }
    }
    
    private var updatedAtBinder: Binder<String> {
        return Binder(updatedAtLabel) { label, text in
            label.isHidden = false
            label.text = text
        }
    }
    
    private var navigationBinder: Binder<ConverterCoordinatorRoute> {
        return Binder(self) { host, route in
            host.navigate(to: route)
        }
    }
    
    private var errorBinder: Binder<String> {
        return Binder(self) { host, message in
            host.indicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            host.present(alert, animated: true, completion: nil)
        }
    }
}

private extension ConverterController {
    func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 8
        let cellSize = UIScreen.main.bounds.width / 3 - (spacing  * 2)
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .absolute(cellSize),
                heightDimension: .absolute(cellSize)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(cellSize)
            ),
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = .init(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ConverterController: UITextFieldDelegate {
    @objc func doneButtonTapped() {
        amountField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return true
        }

        if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil || string == "." {
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

            if updatedText == "00" {
                return false
            }

            if updatedText.hasPrefix("00") {
                return false
            }
            
            let dotCount = updatedText.filter { $0 == "." }.count
            if dotCount > 1 {
                return false
            }

            if updatedText.count <= 9 {
                return true
            }
        }

        return false
    }

}


