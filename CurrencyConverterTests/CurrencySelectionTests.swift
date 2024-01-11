//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Abdul Wahab on 02/01/2024.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import CurrencyConverter

class CurrencySelectionViewModelTests: XCTestCase {
    
    var viewModel: CurrencySelectionViewModel!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func testTransform() {
        let inputSelection = PublishSubject<IndexPath>()
        let input = CurrencySelectionViewModel.Input(selection: inputSelection.asSignal(onErrorSignalWith: .empty()))
        
        let mockCurrencyListState: NetworkResponseState<[String: String]> = .success(["USD": "US Dollar"])
        let mockCurrencyListRepository = MockCurrencyListRepository(result: mockCurrencyListState)
        let currencySelectedRelay = BehaviorRelay<String>(value: "")
        viewModel = CurrencySelectionViewModel(currencySelectedRelay: currencySelectedRelay, currencyListRepository: mockCurrencyListRepository)

        let testScheduler = TestScheduler(initialClock: 0)
        
        let output = viewModel.transform(input: input)
        
        let sectionsObserver = testScheduler.createObserver([CurrencySelectionSection].self)
        let errorObserver = testScheduler.createObserver(String.self)
        let loadingObserver = testScheduler.createObserver(Bool.self)
        let dismissObserver = testScheduler.createObserver(Void.self)
        
        output.sections.drive(sectionsObserver).disposed(by: disposeBag)
        output.error.drive(errorObserver).disposed(by: disposeBag)
        output.loading.drive(loadingObserver).disposed(by: disposeBag)
        output.dismiss.drive(dismissObserver).disposed(by: disposeBag)
        
        testScheduler.scheduleAt(1) {
            inputSelection.onNext(IndexPath(item: 0, section: 0))
        }
        
        testScheduler.start()
        
        XCTAssertEqual(sectionsObserver.events, [
            Recorded.next(0, [
                CurrencySelectionSection(items: [
                    CurrencyCellModel(currency: "USD", currencyName: "US Dollar", flag: "🇺🇸")
                ])
            ]),
            Recorded.completed(0)
        ])
        XCTAssertEqual(errorObserver.events, [Recorded.completed(0)])
        XCTAssertEqual(loadingObserver.events, [Recorded.next(0, false), Recorded.completed(0)])
    }
}

class MockCurrencyListRepository: CurrencyListRepository {
    var result: NetworkResponseState<[String: String]>
    
    init(result: NetworkResponseState<[String: String]>) {
        self.result = result
    }
    
    override func fetchCurrencies() -> Observable<NetworkResponseState<[String: String]>> {
        return Observable.just(result)
    }
}

extension CurrencySelectionSection: Equatable {
    public static func == (lhs: CurrencyConverter.CurrencySelectionSection, rhs: CurrencyConverter.CurrencySelectionSection) -> Bool {
        return lhs.items == rhs.items
    }
}

extension CurrencyCellModel: Equatable {
    public static func == (lhs: CurrencyCellModel, rhs: CurrencyCellModel) -> Bool {
        return lhs.currency == rhs.currency
    }
}

