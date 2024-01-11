//
//  NetworkResponseState.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation

enum NetworkResponseState<T> {
    case loading
    case success(T)
    case error(Error)
    
    var data: T? {
        switch self {
        case .success(let data):
            return data
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
