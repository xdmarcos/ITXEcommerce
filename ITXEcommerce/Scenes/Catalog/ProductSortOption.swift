//
//  ProductSortOption.swift
//  ITXEcommerce
//

import Foundation

enum ProductSortOption: String, CaseIterable, Displayable {
    case categoryAZ      = "Category A→Z"
    case categoryZA      = "Category Z→A"
    case priceLowHigh    = "Price ↑"
    case priceHighLow    = "Price ↓"

    var displayName: String {
        self.rawValue
    }
}
