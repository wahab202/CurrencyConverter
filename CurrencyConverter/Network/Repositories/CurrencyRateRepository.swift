//
//  CurrencyRateRepository.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxSwift
import SQLite

class CurrencyRateRepository {
    let networkManager: NetworkManager
    let database: DatabaseManager
    
    init(networkManager: NetworkManager = NetworkManager(),
         database: DatabaseManager = DatabaseManager.shared) {
        self.networkManager = networkManager
        self.database = database
    }
    
    func fetchRate(for currency: String) -> Observable<NetworkResponseState<CurrencyRateDto>> {
        let cachedRates = database.getRatesFromDatabase()
        if !cachedRates.isEmpty {
            print("Cache Rates")
            if currency.isUsd {
                return .just(.success(.init(base: currency, rates: cachedRates)))
            } else {
                return .just(.success(calculateRates(for: currency, with: cachedRates)))
            }
        }
        
        print("Network Rates")
        let target = CurrencyRateTarget(base: "USD")
        let rates = networkManager.exec(target: target, dto: CurrencyRateDto.self)
        
        return rates
            .compactMap { $0.data }
            .withUnretained(self)
            .map { host, usdRates -> CurrencyRateDto in
                host.database.saveRatesToDatabase(rates: usdRates.rates)
                if currency.isUsd {
                    return usdRates
                } else {
                    return host.calculateRates(for: currency, with: usdRates.rates)
                }
            }
            .map { .success($0) }
    }
}

private extension CurrencyRateRepository {
    func calculateRates(for currency: String, with usdRates: [String: Double]) -> CurrencyRateDto {
        guard let usdRateForBaseCurrency = usdRates[currency],
              usdRateForBaseCurrency > 0 else { return .init(base: currency, rates: [:]) }
        
        var rates: [String: Double] = [:]
        for usdRate in usdRates {
            let usdRateCurrencyName = usdRate.key
            let usdRateForCurrency = usdRate.value
            rates[usdRateCurrencyName] = usdRateForCurrency / usdRateForBaseCurrency
        }
        
        return .init(base: currency, rates: rates)
    }
}

extension String {
    var isUsd: Bool {
        return self == "USD"
    }
}
