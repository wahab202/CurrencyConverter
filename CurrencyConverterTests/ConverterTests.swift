//
//  ConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Abdul Wahab on 08/01/2024.
//

import XCTest
import RxSwift
import RxTest
@testable import CurrencyConverter

class ConverterViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testTransform() {
        let mockCurrencyRatesState: NetworkResponseState<CurrencyRateDto> = .success(.init(base: "USD", rates: ["AED": 3.67]))
        let mockCurrencyRatesRepository = MockCurrencyRatesRepository(result: mockCurrencyRatesState)
        
        let mockCurrencyListState: NetworkResponseState<[String: String]> = .success(["AED": "Arab Emirates Dirham"])
        let mockCurrencyListRepository = MockCurrencyListRepository(result: mockCurrencyListState)
        
        let viewModel = ConverterViewModel(rateRepository: mockCurrencyRatesRepository, currencyListRepository: mockCurrencyListRepository)
        let scheduler = TestScheduler(initialClock: 0)
        let inputAmount = scheduler.createHotObservable([.next(0, "10.0")])
        let selectCurrency = scheduler.createHotObservable([.next(10, ())])
        let offsetChanged = scheduler.createHotObservable([.next(20, ())])
        let input = ConverterViewModel.Input(amount: inputAmount.asSignal(onErrorJustReturn: ""),
                                             selectCurrency: selectCurrency.asSignal(onErrorJustReturn: ()),
                                             offsetChanged: offsetChanged.asSignal(onErrorJustReturn: ()))
        
        let output = viewModel.transform(input: input)
        let sectionsObserver = scheduler.createObserver([ConverterSection].self)

        output.sections.drive(sectionsObserver).disposed(by: disposeBag)

        scheduler.start()
        
        XCTAssertEqual(sectionsObserver.events, [
            Recorded.next(0, [
                ConverterSection(items: [
                    ConvertedCurrencyModel(currency: "AED", amount: 36.7, country: "🇦🇪")
                ])
            ])
        ])
    }
}

class MockCurrencyRatesRepository: CurrencyRateRepository {
    var result: NetworkResponseState<CurrencyRateDto>
    
    init(result: NetworkResponseState<CurrencyRateDto>) {
        self.result = result
    }
    
    override func fetchRate(for currency: String) -> Observable<NetworkResponseState<CurrencyRateDto>> {
        return Observable.just(result)
    }
}


extension ConverterSection: Equatable {
    public static func == (lhs: ConverterSection, rhs: ConverterSection) -> Bool {
        return lhs.items == rhs.items
    }
}

extension ConvertedCurrencyModel: Equatable {
    public static func == (lhs: ConvertedCurrencyModel, rhs: ConvertedCurrencyModel) -> Bool {
        return lhs.currency == rhs.currency && lhs.amount == rhs.amount
    }
    

}
