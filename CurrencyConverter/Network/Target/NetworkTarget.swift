//
//  NetworkTarget.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import Alamofire

protocol NetworkTarget {
    var url: URL { get }
    var params: [String: Any] { get }
    var method: HTTPMethod { get }
}
