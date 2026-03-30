//
//  CatalogViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class CatalogViewModel {
    var products: [Product] = Product.mockProducts
    var columnCount: Int = 2
    var selectedCategory: ProductCategory?
    var cartItemCount = 0
    var showCartDetail = false
    var allCategories = ProductCategory.allCases

    var viewColumns: ColumnsSelectorButton.ColumnsCount {
        .init(rawValue: columnCount) ?? .two
    }

    var filteredProducts: [Product] {
        guard let category = selectedCategory else { return products }
        return products.filter { $0.category == category }
    }

    func cartButtonOnTap() {
        showCartDetail = true
    }

    func columnsSelectorButtonOnTap() {
        columnCount = columnCount == 2 ? 3 : 2
    }
}
