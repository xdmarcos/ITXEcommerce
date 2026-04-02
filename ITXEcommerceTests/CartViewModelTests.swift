//
//  CartViewModelTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import Testing

@Suite("CartViewModel")
@MainActor
struct CartViewModelTests {

    // MARK: Initial state

    @Test func initialItemCountIsZero() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.itemCount == 0)
    }

    @Test func initialTotalPriceIsZero() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.totalPrice == .zero)
    }

    @Test func currencyIsAlwaysEUR() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.currency == "EUR")
    }

    @Test func initialItemsIsEmpty() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.items.isEmpty)
    }

    @Test func initialShowCartDetailIsFalse() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.showCartDetail == false)
    }

    @Test func settingShowCartDetailToTrueOpensCart() {
        let vm = CartViewModel(repository: MockCartRepository())
        vm.showCartDetail = true
        #expect(vm.showCartDetail == true)
    }

    // MARK: Add to cart

    @Test func addProductIncreasesItemCount() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value

        #expect(vm.itemCount == 1)
        #expect(vm.items.count == 1)
    }

    @Test func addingSameProductIncrementsQuantityOnExistingItem() async {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1", stock: 5)
        await vm.add(product: product).value
        await vm.add(product: product).value

        #expect(vm.items.count == 1)
        #expect(vm.itemCount == 2)
    }

    @Test func addingDifferentProductsCreatesSeparateCartItems() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value
        await vm.add(product: makeProduct(id: "P2")).value

        #expect(vm.items.count == 2)
        #expect(vm.itemCount == 2)
    }

    // MARK: Stock limit — add

    @Test func canAddReturnsTrueWhenBelowStockLimit() {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 3)
        #expect(vm.canAdd(product) == true)
    }

    @Test func canAddReturnsFalseWhenStockIsZero() {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 0)
        #expect(vm.canAdd(product) == false)
    }

    @Test func canAddReturnsFalseWhenCartQuantityMatchesStock() async {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 1)

        await vm.add(product: product).value

        #expect(vm.canAdd(product) == false)
    }

    @Test func addDoesNothingWhenAtStockLimit() async {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 1)

        await vm.add(product: product).value
        await vm.add(product: product).value  // should be ignored

        #expect(vm.itemCount == 1)
    }

    // MARK: Stock limit — increase

    @Test func canIncreaseReturnsTrueWhenBelowStockLimit() async {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 2)

        await vm.add(product: product).value

        let item = vm.items.first!  // swiftlint:disable:this force_unwrapping
        #expect(vm.canIncrease(item) == true)
    }

    @Test func canIncreaseReturnsFalseWhenAtStockLimit() async {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 1)

        await vm.add(product: product).value

        let item = vm.items.first!  // swiftlint:disable:this force_unwrapping
        #expect(vm.canIncrease(item) == false)
    }

    @Test func increaseQuantityDoesNothingWhenAtStockLimit() async throws {
        let vm = CartViewModel(repository: MockCartRepository())
        let product = makeProduct(id: "P1", stock: 1)

        await vm.add(product: product).value

        let item = try #require(vm.items.first)
        await vm.increaseQuantity(item).value

        #expect(vm.itemCount == 1)
    }

    // MARK: Total price

    @Test func totalPriceSumsAllItems() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1", price: 10.00)).value
        await vm.add(product: makeProduct(id: "P2", price: 25.00)).value

        #expect(vm.totalPrice == 35.00)
    }

    @Test func totalPriceMultipliesPriceByQuantity() async {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1", price: 15.00, stock: 5)
        await vm.add(product: product).value
        await vm.add(product: product).value

        #expect(vm.totalPrice == 30.00)
    }

    // MARK: Quantity changes

    @Test func increaseQuantityAddsOne() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1", stock: 5)).value

        let item = try #require(vm.items.first)
        await vm.increaseQuantity(item).value

        #expect(vm.itemCount == 2)
    }

    @Test func decreaseQuantityAboveOneDecrementsCount() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1", stock: 5)
        await vm.add(product: product).value
        await vm.add(product: product).value

        let item = try #require(vm.items.first)
        await vm.decreaseQuantity(item).value

        #expect(vm.itemCount == 1)
        #expect(vm.items.count == 1)
    }

    @Test func decreaseQuantityFromOneRemovesItem() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value

        let item = try #require(vm.items.first)
        await vm.decreaseQuantity(item).value

        #expect(vm.items.isEmpty)
        #expect(vm.itemCount == 0)
    }

    // MARK: Remove items

    @Test func removeItemDeletesItFromCart() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value
        await vm.add(product: makeProduct(id: "P2")).value

        let item = try #require(vm.items.first)
        await vm.remove(item).value

        #expect(vm.items.count == 1)
    }

    @Test func onDeleteRemovesItemsAtGivenIndexSet() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value
        await vm.add(product: makeProduct(id: "P2")).value

        await vm.onDelete(IndexSet([0])).value

        #expect(vm.items.count == 1)
    }

    @Test func onDeleteRemovesAllItemsWhenFullIndexSetGiven() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1")).value
        await vm.add(product: makeProduct(id: "P2")).value

        await vm.onDelete(IndexSet([0, 1])).value

        #expect(vm.items.isEmpty)
    }

    // MARK: Checkout

    @Test func checkoutCompletedIsFalseInitially() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.checkoutCompleted == false)
    }

    @Test func checkoutClearsAllItems() async {
        let vm = CartViewModel(repository: MockCartRepository())
        await vm.add(product: makeProduct(id: "P1")).value
        await vm.add(product: makeProduct(id: "P2")).value

        await vm.checkout().value

        #expect(vm.items.isEmpty)
        #expect(vm.itemCount == 0)
    }

    @Test func checkoutSetsCheckoutCompleted() async {
        let vm = CartViewModel(repository: MockCartRepository())
        await vm.add(product: makeProduct(id: "P1")).value

        await vm.checkout().value

        #expect(vm.checkoutCompleted == true)
    }

    @Test func clearCheckoutCompletedResetsFlag() async {
        let vm = CartViewModel(repository: MockCartRepository())
        await vm.add(product: makeProduct(id: "P1")).value
        await vm.checkout().value

        vm.clearCheckoutCompleted()

        #expect(vm.checkoutCompleted == false)
    }

    @Test func checkoutFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())

        await vm.checkout().value

        #expect(vm.lastError != nil)
        #expect(vm.checkoutCompleted == false)
    }

    // MARK: Error handling

    @Test func fetchItemsFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        await vm.loadTask?.value
        #expect(vm.lastError != nil)
    }

    @Test func clearLastErrorNilsError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        await vm.loadTask?.value

        vm.clearLastError()

        #expect(vm.lastError == nil)
    }

    @Test func addFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        let product = makeProduct(id: "P1", stock: 5)

        await vm.add(product: product).value

        #expect(vm.lastError != nil)
    }

    @Test func increaseQuantityFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        let item = CartItem(product: makeProduct(id: "P1", stock: 5))

        await vm.increaseQuantity(item).value

        #expect(vm.lastError != nil)
    }

    @Test func decreaseQuantityFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        let item = CartItem(product: makeProduct(id: "P1"))

        await vm.decreaseQuantity(item).value

        #expect(vm.lastError != nil)
    }

    @Test func removeFailureSetsLastError() async {
        let vm = CartViewModel(repository: FailingCartRepository())
        let item = CartItem(product: makeProduct(id: "P1"))

        await vm.remove(item).value

        #expect(vm.lastError != nil)
    }
}

// MARK: - Helpers

private extension CartViewModelTests {

    func makeProduct(
        id: String = UUID().uuidString,
        price: Decimal = 10.00,
        stock: Int = 1
    ) -> Product {
        Product(
            productId: id,
            sku: "SKU-1234",
            title: "Test Product",
            brand: "Test Brand",
            productDescription: "Test Description",
            category: .beauty,
            price: price,
            stock: stock
        )
    }

    final class FailingCartRepository: CartRepositoryProtocol {
        struct CartError: Error {}
        func fetchItems() throws -> [CartItem] { throw CartError() }
        func add(product: Product) throws { throw CartError() }
        func updateQuantity(_ item: CartItem, to quantity: Int) throws { throw CartError() }
        func remove(_ item: CartItem) throws { throw CartError() }
        func clear() throws { throw CartError() }
    }
}
