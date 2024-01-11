//
//  CurrencyListRepository.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxSwift

class CurrencyListRepository {
    let networkManager: NetworkManager
    let database: DatabaseManager
    
    init(networkManager: NetworkManager = NetworkManager(),
         database: DatabaseManager = DatabaseManager.shared) {
        self.networkManager = networkManager
        self.database = database
    }
    
    func fetchCurrencies() -> Observable<NetworkResponseState<[String: String]>> {
        let cachedCurrencies = database.getCurrenciesFromDatabase()
        if !cachedCurrencies.isEmpty {
            print("Cache Currency")
            return .just(.success(cachedCurrencies))
        }
        
        print("Network Currency")
        let target = CurrencyListTarget()
        return networkManager.exec(target: target, dto: [String: String].self)
            .do(onNext: { [weak self] in
                if let currencies = $0.data {
                    self?.database.saveCurrenciesToDatabase(currencies: currencies)
                }
            })
    }
}
