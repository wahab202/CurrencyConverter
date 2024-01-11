//
//  CurrencyRateDto.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation

struct CurrencyRateDto: Codable {
    let base: String
    let rates: [String: Double]
}
