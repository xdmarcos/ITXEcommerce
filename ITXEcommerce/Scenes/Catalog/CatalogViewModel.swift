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
    private(set) var loadTask: Task<Void, Never>?

    let allCategories = ProductCategory.allCases
    let allSortOption = ProductSortOption.allCases
    var columnCount: Int = 2
    var selectedCategory: ProductCategory?
    var selectedSort: ProductSortOption?
    var selectedProduct: Product?
    var showErrorAlert = false
    var firstLoadCompleted = false
    private(set) var isLoadingMore = false
    private(set) var hasMore = true

    private static let pageSize = 20
    private var currentSkip = 0

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
    }

    var viewColumns: ColumnsSelectorButton.ColumnsCount {
        .init(rawValue: columnCount) ?? .two
    }

    var filteredProducts: [Product] {
        let filtered = selectedCategory.map { cat in products.filter { $0.category == cat } } ?? products
        switch selectedSort {
        case .none: return filtered
        case .categoryAZ: return filtered.sorted { $0.category.displayName < $1.category.displayName }
        case .categoryZA: return filtered.sorted { $0.category.displayName > $1.category.displayName }
        case .priceLowHigh: return filtered.sorted { $0.price < $1.price }
        case .priceHighLow: return filtered.sorted { $0.price > $1.price }
        }
    }

    @discardableResult
    func onFirstAppear() -> Task<Void, Never> {
        if let loadTask { return loadTask }
        let task = Task {
            defer { firstLoadCompleted = true }
            await self.fetchProducts()
        }
        loadTask = task
        return task
    }

    func clearLoadError() {
        loadError = nil
        showErrorAlert = false
    }

    func columnsSelectorButtonOnTap() {
        columnCount = columnCount == 2 ? 3 : 2
    }

    @discardableResult
    func reload() -> Task<Void, Never> {
        let task = Task { await fetchProducts() }
        return task
    }

    @discardableResult
    func loadNextPage() -> Task<Void, Never>? {
        guard !isLoadingMore, hasMore else { return nil }
        return Task { await fetchNextPage() }
    }

    private func fetchProducts() async {
        currentSkip = 0
        products = []
        hasMore = true
        await fetchNextPage()
    }

    private func fetchNextPage() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let (newProducts, total) = try await repository.fetchPage(skip: currentSkip, limit: Self.pageSize)
            products += newProducts
            currentSkip += newProducts.count
            hasMore = currentSkip < total
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
