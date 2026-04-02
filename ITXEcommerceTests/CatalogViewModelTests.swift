//
//  CatalogViewModelTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import Testing

@Suite("CatalogViewModel")
@MainActor
struct CatalogViewModelTests {

    // MARK: Initial state

    @Test func initialColumnCountIsTwo() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.columnCount == 2)
    }

    @Test func initialSelectedCategoryIsNil() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.selectedCategory == nil)
    }

    @Test func allCategoriesMatchesProductCategoryAllCases() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.allCategories == ProductCategory.allCases)
    }

    // MARK: Product loading

    @Test func loadsProductsOnInit() async {
        let products = [makeProduct(id: "1"), makeProduct(id: "2"), makeProduct(id: "3")]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))

        await vm.onFirstAppear().value

        #expect(vm.products.count == 3)
    }

    @Test func fetchFailureSetsLoadErrorAndAlert() async {
        let vm = CatalogViewModel(repository: FailingProductRepository())

        await vm.onFirstAppear().value

        #expect(vm.catalogError != nil)
    }

    @Test func clearLoadErrorResetsErrorState() async {
        let vm = CatalogViewModel(repository: FailingProductRepository())
        await vm.onFirstAppear().value

        vm.clearLoadError()

        #expect(vm.catalogError == nil)
    }

    @Test func successfulFetchClearsErrorState() async {
        let vm = CatalogViewModel(repository: MockProductRepository(products: [makeProduct()]))
        await vm.onFirstAppear().value

        #expect(vm.catalogError == nil)
    }

    // MARK: Category filtering

    @Test func filteredProductsReturnsAllWhenNoCategorySelected() async {
        let products = [
            makeProduct(id: "1", category: .beauty),
            makeProduct(id: "2", category: .laptops),
            makeProduct(id: "3", category: .tops)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedCategory = nil

        #expect(vm.filteredProducts.count == 3)
    }

    @Test func filteredProductsFiltersBySelectedCategory() async {
        let products = [
            makeProduct(id: "1", category: .beauty),
            makeProduct(id: "2", category: .beauty),
            makeProduct(id: "3", category: .laptops),
            makeProduct(id: "4", category: .tops)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedCategory = .beauty

        #expect(vm.filteredProducts.count == 2)
    }

    @Test func filteredProductsIsEmptyWhenNothingMatchesCategory() async {
        let products = [makeProduct(id: "1", category: .beauty)]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedCategory = .laptops

        #expect(vm.filteredProducts.isEmpty)
    }

    // MARK: Sort options

    @Test func defaultSortIsNil() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.selectedSort == nil)
    }

    @Test func noSortPreservesLoadOrder() async {
        let products = [
            makeProduct(id: "1", price: 50.00),
            makeProduct(id: "2", price: 10.00),
            makeProduct(id: "3", price: 30.00)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = nil

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["1", "2", "3"])
    }

    @Test func sortByPriceLowHighOrdersAscending() async {
        let products = [
            makeProduct(id: "A", price: 50.00),
            makeProduct(id: "B", price: 10.00),
            makeProduct(id: "C", price: 30.00)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = .priceLowHigh

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["B", "C", "A"])
    }

    @Test func sortByPriceHighLowOrdersDescending() async {
        let products = [
            makeProduct(id: "A", price: 50.00),
            makeProduct(id: "B", price: 10.00),
            makeProduct(id: "C", price: 30.00)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = .priceHighLow

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["A", "C", "B"])
    }

    @Test func sortByCategoryAZOrdersAlphabetically() async {
        let products = [
            makeProduct(id: "W", category: .womensDresses),
            makeProduct(id: "B", category: .beauty),
            makeProduct(id: "L", category: .laptops)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = .categoryAZ

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["B", "L", "W"])
    }

    @Test func sortByCategoryZAOrdersReverseAlphabetically() async {
        let products = [
            makeProduct(id: "W", category: .womensDresses),
            makeProduct(id: "B", category: .beauty),
            makeProduct(id: "L", category: .laptops)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = .categoryZA

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["W", "L", "B"])
    }

    @Test func resettingSortToNilRestoresOriginalOrder() async {
        let products = [
            makeProduct(id: "1", price: 50.00),
            makeProduct(id: "2", price: 10.00),
            makeProduct(id: "3", price: 30.00)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedSort = .priceLowHigh
        vm.selectedSort = nil

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["1", "2", "3"])
    }

    @Test func categoryFilterAndSortApplyTogether() async {
        let products = [
            makeProduct(id: "B1", category: .beauty, price: 40.00),
            makeProduct(id: "B2", category: .beauty, price: 10.00),
            makeProduct(id: "L1", category: .laptops, price: 20.00)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedCategory = .beauty
        vm.selectedSort = .priceLowHigh

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["B2", "B1"])
    }

    // MARK: Column selector

    @Test func columnsSelectorTogglesTwoToThree() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        vm.columnsSelectorButtonOnTap()
        #expect(vm.columnCount == 3)
    }

    @Test func columnsSelectorTogglesThreeBackToTwo() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        vm.columnsSelectorButtonOnTap()
        vm.columnsSelectorButtonOnTap()
        #expect(vm.columnCount == 2)
    }

    @Test func viewColumnsReflectsColumnCount() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.viewColumns == .two)
        vm.columnsSelectorButtonOnTap()
        #expect(vm.viewColumns == .three)
    }

    // MARK: Pagination

    @Test func initialHasMoreIsTrue() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.hasMore == true)
    }

    @Test func initialIsLoadingMoreIsFalse() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.isLoadingMore == false)
    }

    @Test func firstLoadCompletedIsFalseBeforeFirstAppear() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.firstLoadCompleted == false)
    }

    @Test func firstLoadCompletedIsTrueAfterFirstAppear() async {
        let vm = CatalogViewModel(repository: MockProductRepository(products: [makeProduct()]))
        await vm.onFirstAppear().value
        #expect(vm.firstLoadCompleted == true)
    }

    @Test func isLoadingMoreIsFalseAfterLoadCompletes() async {
        let products = (1...5).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value
        #expect(vm.isLoadingMore == false)
    }

    @Test func loadsFirstPageOf20Products() async {
        let products = (1...30).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))

        await vm.onFirstAppear().value

        #expect(vm.products.count == 20)
    }

    @Test func hasMoreIsTrueWhenMorePagesExist() async {
        let products = (1...30).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))

        await vm.onFirstAppear().value

        #expect(vm.hasMore == true)
    }

    @Test func hasMoreIsFalseWhenAllProductsFitInOnePage() async {
        let products = (1...10).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))

        await vm.onFirstAppear().value

        #expect(vm.hasMore == false)
    }

    @Test func loadNextPageAppendsProducts() async {
        let products = (1...30).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        await vm.loadNextPage()?.value

        #expect(vm.products.count == 30)
        #expect(vm.hasMore == false)
    }

    @Test func loadNextPageReturnsNilWhenNoMore() async {
        let products = (1...5).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        let task = vm.loadNextPage()

        #expect(task == nil)
        #expect(vm.products.count == 5)
    }

    @Test func consecutiveLoadNextPageCallsDoNotDuplicateProducts() async {
        let products = (1...30).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        let t1 = vm.loadNextPage()
        let t2 = vm.loadNextPage()
        await t1?.value
        await t2?.value

        #expect(vm.products.count == 30)
    }

    @Test func reloadResetsPaginationState() async {
        let products = (1...30).map { makeProduct(id: "\($0)") }
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value
        #expect(vm.products.count == 20)

        await vm.reload().value

        #expect(vm.products.count == 20)
    }

    // MARK: Search

    @Test func initialSearchTextIsEmpty() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.searchText == "")
    }

    @Test func emptySearchTextReturnsAllProducts() async {
        let products = [
            makeProduct(id: "1", title: "iPhone"),
            makeProduct(id: "2", title: "MacBook"),
            makeProduct(id: "3", title: "iPad")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = ""

        #expect(vm.filteredProducts.count == 3)
    }

    @Test func searchFiltersProductsByTitle() async {
        let products = [
            makeProduct(id: "1", title: "iPhone 15"),
            makeProduct(id: "2", title: "MacBook Pro"),
            makeProduct(id: "3", title: "iPhone 14")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "iPhone"

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["1", "3"])
    }

    @Test func searchIsCaseInsensitive() async {
        let products = [
            makeProduct(id: "1", title: "iPhone 15"),
            makeProduct(id: "2", title: "MacBook Pro")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "iphone"

        #expect(vm.filteredProducts.count == 1)
        #expect(vm.filteredProducts.first?.productId == "1")
    }

    @Test func searchMatchesPartialTitle() async {
        let products = [
            makeProduct(id: "1", title: "Wireless Headphones"),
            makeProduct(id: "2", title: "Wired Keyboard")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "wire"

        #expect(vm.filteredProducts.count == 2)
    }

    @Test func searchWithNoMatchReturnsEmpty() async {
        let products = [
            makeProduct(id: "1", title: "iPhone"),
            makeProduct(id: "2", title: "MacBook")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "Samsung"

        #expect(vm.filteredProducts.isEmpty)
    }

    @Test func clearingSearchRestoresFullList() async {
        let products = [
            makeProduct(id: "1", title: "iPhone"),
            makeProduct(id: "2", title: "MacBook")
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "iPhone"
        #expect(vm.filteredProducts.count == 1)

        vm.searchText = ""
        #expect(vm.filteredProducts.count == 2)
    }

    @Test func searchAndCategoryFilterApplyTogether() async {
        let products = [
            makeProduct(id: "1", title: "Beauty Serum", category: .beauty),
            makeProduct(id: "2", title: "Beauty Cream", category: .beauty),
            makeProduct(id: "3", title: "Laptop Pro", category: .laptops)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.selectedCategory = .beauty
        vm.searchText = "Serum"

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["1"])
    }

    @Test func searchAndSortApplyTogether() async {
        let products = [
            makeProduct(id: "1", title: "iPhone 15", price: 999),
            makeProduct(id: "2", title: "iPhone 14", price: 799),
            makeProduct(id: "3", title: "MacBook Pro", price: 1299)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.onFirstAppear().value

        vm.searchText = "iPhone"
        vm.selectedSort = .priceLowHigh

        let ids = vm.filteredProducts.map(\.productId)
        #expect(ids == ["2", "1"])
    }
}

// MARK: - Helpers

private extension CatalogViewModelTests {

    func makeProduct(
        id: String = UUID().uuidString,
        title: String = "Test Product",
        category: ProductCategory = .beauty,
        price: Decimal = 29.99
    ) -> Product {
        Product(
            productId: id,
            sku: "SKU-1234",
            title: title,
            brand: "Test Brand",
            productDescription: "Test Description",
            category: category,
            price: price
        )
    }

    final class FailingProductRepository: ProductRepositoryProtocol {
        struct FetchError: Error {}
        func fetchAll() async throws -> [Product] { throw FetchError() }
        func fetch(category: ProductCategory?) async throws -> [Product] { throw FetchError() }
        func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) { throw FetchError() }
        func fetchProduct(id: String) async throws -> Product? { throw FetchError() }
    }
}
