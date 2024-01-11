//
//  CurrencyListTarget.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import Alamofire

struct CurrencyListTarget: NetworkTarget {
    var url: URL {
        URL(string: "https://openexchangerates.org/api/currencies.json")!
    }
    
    var params: [String : Any] {
        [:]
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
}
