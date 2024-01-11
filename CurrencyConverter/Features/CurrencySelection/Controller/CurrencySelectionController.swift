//
//  CurrencySelectionController.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CurrencySelectionController: UIViewController {
    
    private lazy var cv: UICollectionView = {
        let layout = createLayout()
        
        let cv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.allowsSelection = true
        cv.register(CurrencySelectionCell.self, forCellWithReuseIdentifier: "CurrencySelectionCell")
        return cv
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let bag: DisposeBag
    private let vm: CurrencySelectionViewModel
    
    init(vm: CurrencySelectionViewModel) {
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
                
        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
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
        let input = CurrencySelectionViewModel.Input(
            selection: cv.rx.itemSelected.asSignal()
        )

        let output = vm.transform(input: input)

        let dataSource = RxCollectionViewSectionedReloadDataSource<CurrencySelectionSection>(
            configureCell: { dataSource, collectionView, indexPath, model in
                let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: "CurrencySelectionCell", for: indexPath) as! CurrencySelectionCell
                return cell.bind(model: model)
        })
            
        let disposables = [
            output.sections.drive(cv.rx.items(dataSource: dataSource)),
            output.error.drive(errorBinder),
            output.loading.drive(indicator.rx.isAnimating),
            output.dismiss.drive(dismissBinder)
        ]

        disposables.forEach { $0.disposed(by: bag) }
    }
    
    private var errorBinder: Binder<String> {
        return Binder(self) { host, message in
            host.indicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            host.present(alert, animated: true, completion: nil)
        }
    }
    
    private var dismissBinder: Binder<()> {
        return Binder(self) { host, _ in
            host.dismiss(animated: true)
        }
    }
}

private extension CurrencySelectionController {
    func createLayout() -> UICollectionViewLayout {
        let height: CGFloat = 45.0
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(height)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(height)
            ),
            subitems: [item]
        )
                
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


