//
//  CurrencySelectionSection.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 04/01/2024.
//

import Foundation
import RxDataSources

struct CurrencySelectionSection {
  var items: [Item]
}

extension CurrencySelectionSection: SectionModelType {
  typealias Item = CurrencyCellModel

   init(original: CurrencySelectionSection, items: [Item]) {
    self = original
    self.items = items
  }
}
