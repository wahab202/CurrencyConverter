//
//  CurrencyRateTarget.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import Alamofire

struct CurrencyRateTarget: NetworkTarget {
    
    private let base: String
    
    init(base: String) {
        self.base = base
    }
    
    var url: URL {
        URL(string: "https://openexchangerates.org/api/latest.json")!
    }
    
    var params: [String : Any] {
        [
            "app_id":"e33f06b0b8f04172b2a66fd91f7c0cb9",
            "base": base
        ]
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
}
