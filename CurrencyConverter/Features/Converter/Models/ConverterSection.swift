//
//  ConverterSection.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import Foundation
import RxDataSources

struct ConverterSection {
  var items: [Item]
}

extension ConverterSection: SectionModelType {
  typealias Item = ConvertedCurrencyModel

   init(original: ConverterSection, items: [Item]) {
    self = original
    self.items = items
  }
}
