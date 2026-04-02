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
    private static let pageSize = 20
    private var currentSkip = 0

    private(set) var products: [Product] = []
    private(set) var loadTask: Task<Void, Never>?
    private(set) var isLoadingMore = false
    private(set) var hasMore = true

    let allCategories = ProductCategory.allCases
    let allSortOption = ProductSortOption.allCases
    var columnCount: Int = 2
    var searchText: String = ""
    var selectedCategory: ProductCategory?
    var selectedSort: ProductSortOption?
    var selectedProduct: Product?
    var firstLoadCompleted = false
    var catalogError: Error?

    enum CatalogError: LocalizedError {
        case unknown(Error? = nil)
        case loadError(Error? = nil)

        var errorDescription: LocalizedStringResource? {
            switch self {
            case .unknown: return "Unknown Error"
            case .loadError: return "Failed to load products"
            }
        }

        var recoverySuggestion: LocalizedStringResource? {
            switch self {
            case .unknown(let error): return LocalizedStringResource(stringLiteral: error?.localizedDescription ?? "")
            case .loadError: return "An unexpected error occurred. Please try again later."
            }
        }
    }

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
    }

    var viewColumns: ColumnsSelectorButton.ColumnsCount {
        .init(rawValue: columnCount) ?? .two
    }

    var filteredProducts: [Product] {
        let byCategory = selectedCategory.map { cat in products.filter { $0.category == cat } } ?? products
        let filtered = searchText.isEmpty
            ? byCategory
            : byCategory.filter { $0.title.localizedStandardContains(searchText) }
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
            await self.fetchProducts()
            firstLoadCompleted = true
        }
        loadTask = task
        return task
    }

    func clearLoadError() {
        catalogError = nil
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
            catalogError = CatalogError.loadError(error)
        }
    }
}
