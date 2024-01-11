//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxSwift
import RxCocoa

final class ConverterViewModel {
    
    private let rateRepository: CurrencyRateRepository
    private let currencyListRepository: CurrencyListRepository
    private let countryCurrencyDatabase: CurrencyToCountryDatabase
    private let databaseManager: DatabaseManager
        
    init(
        rateRepository: CurrencyRateRepository = CurrencyRateRepository(),
        currencyListRepository: CurrencyListRepository = CurrencyListRepository(),
        countryCurrencyDatabase: CurrencyToCountryDatabase = CurrencyToCountryDatabase(),
        databaseManager: DatabaseManager = DatabaseManager.shared
    ) {
        self.rateRepository = rateRepository
        self.currencyListRepository = currencyListRepository
        self.countryCurrencyDatabase = countryCurrencyDatabase
        self.databaseManager = databaseManager
    }
}

extension ConverterViewModel {
    typealias Route = ConverterCoordinatorRoute
    
    struct Input {
        let amount: Signal<String>
        let selectCurrency: Signal<()>
        let offsetChanged: Signal<()>
    }
    
    struct Output {
        let currency: Driver<String>
        let country: Driver<String?>
        let sections: Driver<[ConverterSection]>
        let error: Driver<String>
        let loading: Driver<Bool>
        let updatedAt: Driver<String>
        let navigation: Driver<Route>
        let offsetChanged: Driver<()>
    }
    
    func transform(input: Input) -> Output {
        let base: BehaviorRelay<String> = .init(value: "USD")
        
        let amount = input.amount
            .map { Double($0) }
            .compactMap { $0 }
            .asObservable()
        
        let ratesResponseState = base.asObservable()
            .withUnretained(self)
            .flatMapLatest { host, base in
                host.rateRepository.fetchRate(for: base)
            }
            .share(replay: 1)
        
        let ratesResponse = ratesResponseState
            .compactMap { $0.data }
        
        let items = Observable.combineLatest(ratesResponse, base.asObservable(), amount)
            .withUnretained(self)
            .map { host, args -> [ConvertedCurrencyModel] in
                let (ratesResponse, _, amount) = args
                var items: [ConvertedCurrencyModel] = []
                ratesResponse.rates.forEach {
                    let country = host.countryCurrencyDatabase.getFlagEmoji(forCurrencyCode: $0.key)
                    items.append(.init(currency: $0.key, amount: amount * $0.value, country: country))
                }
                return items.sorted(by: { $0.currency < $1.currency })
        }
        
        let sections = items.map { rateItems -> [ConverterSection] in
             return [ ConverterSection(items: rateItems)]
        }.asDriver(onErrorDriveWith: .empty())
        
        let error = ratesResponseState
            .compactMap { $0.error?.localizedDescription }
            .asDriver(onErrorDriveWith: .empty())
        
        let loading = ratesResponseState
            .map { $0.isLoading }
            .asDriver(onErrorDriveWith: .empty())
        
        let currency = base.asDriver()
        
        let country = base
            .withUnretained(self)
            .map { host, currency -> String? in
                host.countryCurrencyDatabase.getFlagEmoji(forCurrencyCode: currency)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let navigation = input.selectCurrency
            .map { _ in Route.currencySelection(selectionRelay: base) }
            .asDriver(onErrorDriveWith: .never())
        
        let updatedAt = ratesResponseState
            .withUnretained(self)
            .map { host, _ in
                host.databaseManager.timeSinceRatesUpdated()
            }
            .compactMap { $0 }
            .map { seconds in
                let minutes = Int(seconds / 60)
                return minutes > 1 ? "Updated: \(minutes) mins ago" : "Updated: just now"
            }
            .asDriver(onErrorDriveWith: .never())
        
        let offsetChanged = input.offsetChanged.asDriver(onErrorDriveWith: .never())
        
        return Output(
            currency: currency,
            country: country,
            sections: sections,
            error: error,
            loading: loading,
            updatedAt: updatedAt,
            navigation: navigation,
            offsetChanged: offsetChanged
        )
    }
}
