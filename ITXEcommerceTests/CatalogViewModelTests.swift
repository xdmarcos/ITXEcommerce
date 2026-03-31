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

    @Test func initialShowCartDetailIsFalse() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        #expect(vm.showCartDetail == false)
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

        await vm.loadTask?.value

        #expect(vm.products.count == 3)
    }

    @Test func fetchFailureSetsLoadErrorAndAlert() async {
        let vm = CatalogViewModel(repository: FailingProductRepository())

        await vm.loadTask?.value

        #expect(vm.loadError != nil)
        #expect(vm.showErrorAlert == true)
    }

    @Test func clearLoadErrorResetsErrorState() async {
        let vm = CatalogViewModel(repository: FailingProductRepository())
        await vm.loadTask?.value

        vm.clearLoadError()

        #expect(vm.loadError == nil)
        #expect(vm.showErrorAlert == false)
    }

    @Test func successfulFetchClearsErrorState() async {
        let vm = CatalogViewModel(repository: MockProductRepository(products: [makeProduct()]))
        await vm.loadTask?.value

        #expect(vm.loadError == nil)
        #expect(vm.showErrorAlert == false)
    }

    // MARK: Category filtering

    @Test func filteredProductsReturnsAllWhenNoCategorySelected() async {
        let products = [
            makeProduct(id: "1", category: .shirt),
            makeProduct(id: "2", category: .denim),
            makeProduct(id: "3", category: .trousers)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.loadTask?.value

        vm.selectedCategory = nil

        #expect(vm.filteredProducts.count == 3)
    }

    @Test func filteredProductsFiltersBySelectedCategory() async {
        let products = [
            makeProduct(id: "1", category: .shirt),
            makeProduct(id: "2", category: .shirt),
            makeProduct(id: "3", category: .denim),
            makeProduct(id: "4", category: .trousers)
        ]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.loadTask?.value

        vm.selectedCategory = .shirt

        #expect(vm.filteredProducts.count == 2)
    }

    @Test func filteredProductsIsEmptyWhenNothingMatchesCategory() async {
        let products = [makeProduct(id: "1", category: .shirt)]
        let vm = CatalogViewModel(repository: MockProductRepository(products: products))
        await vm.loadTask?.value

        vm.selectedCategory = .jacket

        #expect(vm.filteredProducts.isEmpty)
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

    // MARK: Cart button

    @Test func cartButtonOnTapSetsShowCartDetail() {
        let vm = CatalogViewModel(repository: MockProductRepository())
        vm.cartButtonOnTap()
        #expect(vm.showCartDetail == true)
    }
}

// MARK: - Helpers

fileprivate func makeProduct(
    id: String = UUID().uuidString,
    category: ProductCategory = .shirt,
    price: Decimal = 29.99
) -> Product {
    Product(
        productId: id,
        name: "Test Product",
        brand: "Test Brand",
        productDescription: "Test Description",
        category: category,
        price: price
    )
}

fileprivate final class FailingProductRepository: ProductRepositoryProtocol {
    struct FetchError: Error {}
    func fetchAll() async throws -> [Product] { throw FetchError() }
    func fetch(category: ProductCategory?) async throws -> [Product] { throw FetchError() }
}
