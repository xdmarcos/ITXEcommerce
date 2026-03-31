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

    @ObservationIgnored
    private(set) var loadTask: Task<Void, Never>?

    let allCategories = ProductCategory.allCases
    var columnCount: Int = 2
    var selectedCategory: ProductCategory?
    var selectedProduct: Product?
    var showCartDetail = false
    var showErrorAlert = false

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
        loadTask = Task { await self.fetchProducts() }
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
        showErrorAlert = false
    }

    func cartButtonOnTap() {
        showCartDetail = true
    }

    func columnsSelectorButtonOnTap() {
        columnCount = columnCount == 2 ? 3 : 2
    }

    @discardableResult
    func reload() -> Task<Void, Never> {
        let task = Task { await fetchProducts() }
        loadTask = task
        return task
    }

    private func fetchProducts() async {
        do {
            products = try await repository.fetchAll()
            clearLoadError()
        } catch {
            loadError = error
            showErrorAlert = true
        }
    }

    private func reload(for category: ProductCategory?) {
        Task {
            do {
                products = try await repository.fetch(category: category)
                clearLoadError()
            } catch {
                loadError = error
                showErrorAlert = true
            }
        }
    }
}
