//
//  CatalogViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class CatalogViewModel {
    private let repository: any ProductRepositoryProtocol
    private(set) var products: [Product] = []

    let allCategories = ProductCategory.allCases
    var columnCount: Int = 2
    var selectedCategory: ProductCategory?
    var showCartDetail = false

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
        reload()
    }

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

    func reload() {
        products = (try? repository.fetchAll()) ?? []
    }

    private func reload(for category: ProductCategory?) {
        products = (try? repository.fetch(category: category)) ?? []
    }
}
