//
//  NetworkManager.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxSwift
import Alamofire

class NetworkManager {
    
    func exec<ResponseDto: Decodable>(target: NetworkTarget,
                                      dto: ResponseDto.Type) -> Observable<NetworkResponseState<ResponseDto>> {
        return Observable.create { observer in
            observer.onNext(.loading)

            let request = AF.request(target.url,
                                     method: target.method,
                                     parameters: target.params)
            request.responseDecodable(of: dto.self) { (response) in
                switch response.result {
                case .success(let data):
                    observer.onNext(.success(data))
                case .failure(let error):
                    observer.onNext(.error(error))
                }
                observer.onCompleted()
            }
                        
            return Disposables.create()
        }
    }
}
