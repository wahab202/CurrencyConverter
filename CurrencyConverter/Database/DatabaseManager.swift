//
//  DatabaseManager.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 05/01/2024.
//

import Foundation
import SQLite

class DatabaseManager {
    enum Constants {
        static let currencyRatesUpdatedAtKey: String = "currencyRatesUpdatedAt"
        static let currencyListUpdatedAtKey: String = "currencyListUpdatedAtKey"
    }
    
    static let shared = DatabaseManager()
    
    private var db: Connection?
    
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/exchange_rates.sqlite3")
            
            if !tableExists("rates") {
                createRatesTable()
            }
            if !tableExists("currencies") {
                createCurrenciesTable()
            }
        } catch {
            print(error)
        }
    }
    
    private func tableExists(_ tableName: String) -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?"
        return try! db!.scalar(query, tableName) != nil
    }
    
    private func createRatesTable() {
        do {
            let ratesTable = Table("rates")
            let currency = Expression<String>("currency")
            let rate = Expression<Double>("rate")
            
            try db?.run(ratesTable.create { t in
                t.column(currency, primaryKey: true)
                t.column(rate)
            })
        } catch {
            print(error)
        }
    }
    
    private func createCurrenciesTable() {
        do {
            let currencyTable = Table("currencies")
            let currency = Expression<String>("currency")
            let currencyName = Expression<String>("currencyName")
            
            try db?.run(currencyTable.create { t in
                t.column(currency, primaryKey: true)
                t.column(currencyName)
            })
        } catch {
            print(error)
        }
    }
    
    func saveCurrenciesToDatabase(currencies: [String: String]) {
        do {
            let currencyTable = Table("currencies")
            let currency = Expression<String>("currency")
            let currencyName = Expression<String>("currencyName")
            
            for (key, value) in currencies {
                let existingRecord = currencyTable.filter(currency == key)
                if try db!.run(existingRecord.update(currencyName <- value)) == 0 {
                    try db!.run(currencyTable.insert(currency <- key, currencyName <- value))
                }
            }
            currencyListUpdated()
        } catch {
            print(error)
        }
    }
    
    func getCurrenciesFromDatabase() -> [String: String] {
        guard isCurrencyListUpToDate() else { return [:] }
        
        var result: [String: String] = [:]
        
        do {
            let currencyTable = Table("currencies")
            let currency = Expression<String>("currency")
            let currencyName = Expression<String>("currencyName")
            
            for row in try db!.prepare(currencyTable) {
                result[row[currency]] = row[currencyName]
            }
        } catch {
            print(error)
        }
        
        return result
    }
    
    func saveRatesToDatabase(rates: [String: Double]) {
        do {
            let ratesTable = Table("rates")
            let currency = Expression<String>("currency")
            let rate = Expression<Double>("rate")
            
            for (key, value) in rates {
                let existingRecord = ratesTable.filter(currency == key)
                if try db!.run(existingRecord.update(rate <- value)) == 0 {
                    try db!.run(ratesTable.insert(currency <- key, rate <- value))
                }
            }
            ratesUpdated()
        } catch {
            print(error)
        }
    }
    
    func getRatesFromDatabase() -> [String: Double] {
        guard areRatesUpToDate() else { return [:] }
        
        var result: [String: Double] = [:]
        
        do {
            let ratesTable = Table("rates")
            let currency = Expression<String>("currency")
            let rate = Expression<Double>("rate")
            
            for row in try db!.prepare(ratesTable) {
                result[row[currency]] = row[rate]
            }
        } catch {
            print(error)
        }
        
        return result
    }
    
    func timeSinceRatesUpdated() -> TimeInterval? {
        guard let updatedAt = UserDefaults.standard.object(forKey: Constants.currencyRatesUpdatedAtKey) as? Date else { return nil }
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(updatedAt)
        return timeInterval
    }
    
    private func areRatesUpToDate() -> Bool {
        guard let timeSinceUpdate = timeSinceRatesUpdated() else { return false }
        return timeSinceUpdate < (60 * 30)
    }
    
    private func ratesUpdated() {
        UserDefaults.standard.set(Date(), forKey: Constants.currencyRatesUpdatedAtKey)
    }
    
    func timeSinceCurrencyListUpdated() -> TimeInterval? {
        guard let updatedAt = UserDefaults.standard.object(forKey: Constants.currencyListUpdatedAtKey) as? Date else { return nil }
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(updatedAt)
        return timeInterval
    }
    
    private func isCurrencyListUpToDate() -> Bool {
        guard let timeSinceUpdate = timeSinceCurrencyListUpdated() else { return false }
        return timeSinceUpdate < (60 * 30)
    }
    
    private func currencyListUpdated() {
        UserDefaults.standard.set(Date(), forKey: Constants.currencyListUpdatedAtKey)
    }
}
