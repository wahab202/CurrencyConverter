//
//  CurrencySelectionViewModel.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxSwift
import RxCocoa

final class CurrencySelectionViewModel {
    
    private let currencyListRepository: CurrencyListRepository
    private let countryCurrencyDatabase: CurrencyToCountryDatabase
    private let currencySelectedRelay: BehaviorRelay<String>
        
    init(
        currencySelectedRelay: BehaviorRelay<String>,
        currencyListRepository: CurrencyListRepository = CurrencyListRepository(),
        countryCurrencyDatabase: CurrencyToCountryDatabase = CurrencyToCountryDatabase()
    ) {
        self.currencyListRepository = currencyListRepository
        self.countryCurrencyDatabase = countryCurrencyDatabase
        self.currencySelectedRelay = currencySelectedRelay
    }
}

extension CurrencySelectionViewModel {
    struct Input {
        let selection: Signal<IndexPath>
    }
    
    struct Output {
        let sections: Driver<[CurrencySelectionSection]>
        let error: Driver<String>
        let loading: Driver<Bool>
        let dismiss: Driver<()>
    }
    
    func transform(input: Input) -> Output {
        let currencyListState = currencyListRepository
            .fetchCurrencies()
        
        let currencies = currencyListState
            .compactMap { $0.data }
        
        let items = currencies
            .withUnretained(self)
            .map { host, currencies -> [CurrencyCellModel] in
                var items: [CurrencyCellModel] = []
                for currency in currencies {
                    let flag = host.countryCurrencyDatabase.getFlagEmoji(forCurrencyCode: currency.key)
                    items.append(.init(currency: currency.key, currencyName: currency.value, flag: flag))
                }
                return items.sorted(by: { $0.currency < $1.currency })
            }
        
        let sections = items.map { currencyItems -> [CurrencySelectionSection] in
             return [ CurrencySelectionSection(items: currencyItems) ]
        }.asDriver(onErrorDriveWith: .empty())
        
        let selectedItem = input.selection
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(sections) { idx, sections in
                sections[idx.section].items[idx.item]
            }
        
        let selectedCurrency = selectedItem
            .map { $0.currency }
            .asObservable()
            .withUnretained(self)
            .do(onNext: { host, currency in
                host.currencySelectedRelay.accept(currency)
            })
                
        let dismiss = selectedCurrency
        .map { _ in () }
        .asDriver(onErrorDriveWith: .never())
        
        let error = currencyListState
            .compactMap { $0.error?.localizedDescription }
            .asDriver(onErrorDriveWith: .empty())
        
        let loading = currencyListState
            .map { $0.isLoading }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            sections: sections,
            error: error,
            loading: loading,
            dismiss: dismiss
        )
    }
}
