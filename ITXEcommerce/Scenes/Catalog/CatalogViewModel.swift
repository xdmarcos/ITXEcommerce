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
    private(set) var loadError: Error?

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

    func clearLoadError() {
        loadError = nil
    }

    func cartButtonOnTap() {
        showCartDetail = true
    }

    func columnsSelectorButtonOnTap() {
        columnCount = columnCount == 2 ? 3 : 2
    }

    func reload() {
        do {
            products = try repository.fetchAll()
            loadError = nil
        } catch {
            loadError = error
        }
    }

    private func reload(for category: ProductCategory?) {
        do {
            products = try repository.fetch(category: category)
            loadError = nil
        } catch {
            loadError = error
        }
    }
}
