//
//  ConverterCoordinator.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 04/01/2024.
//

import UIKit
import RxRelay

enum ConverterCoordinatorRoute {
    case currencySelection(selectionRelay: BehaviorRelay<String>)
}

protocol ConverterCoordinator {
    var root: UIViewController { get }
}

extension ConverterCoordinator {
    func navigate(to route: ConverterCoordinatorRoute) {
        switch route {
        case .currencySelection(let relay):
            toCurrencySelection(selectionRelay: relay)
        }
    }
    
    func toCurrencySelection(selectionRelay: BehaviorRelay<String>) {
        let vc = CurrencySelectionController(vm: .init(currencySelectedRelay: selectionRelay))
        vc.modalPresentationStyle = .formSheet
        root.present(vc, animated: true)
    }
}
