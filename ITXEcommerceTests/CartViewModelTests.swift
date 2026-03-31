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

    @Test func defaultCurrencyIsEURWhenCartIsEmpty() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.currency == "EUR")
    }

    @Test func initialItemsIsEmpty() {
        let vm = CartViewModel(repository: MockCartRepository())
        #expect(vm.items.isEmpty)
    }

    // MARK: Add to cart

    @Test func addProductIncreasesItemCount() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1"), size: .m, variantId: "V1").value

        #expect(vm.itemCount == 1)
        #expect(vm.items.count == 1)
    }

    @Test func addingSameProductAndSizeIncrementsQuantityOnExistingItem() async {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1")
        await vm.add(product: product, size: .m, variantId: "V1").value
        await vm.add(product: product, size: .m, variantId: "V1").value

        #expect(vm.items.count == 1)
        #expect(vm.itemCount == 2)
    }

    @Test func addingSameProductWithDifferentSizesCreatesSeperateCartItems() async {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1")
        await vm.add(product: product, size: .s, variantId: "V1").value
        await vm.add(product: product, size: .l, variantId: "V1").value

        #expect(vm.items.count == 2)
        #expect(vm.itemCount == 2)
    }

    // MARK: Total price & currency

    @Test func totalPriceSumsAllItems() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1", price: 10.00), size: .m, variantId: "V1").value
        await vm.add(product: makeProduct(id: "P2", price: 25.00), size: .s, variantId: "V1").value

        #expect(vm.totalPrice == 35.00)
    }

    @Test func totalPriceMultipliesPriceByQuantity() async {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1", price: 15.00)
        await vm.add(product: product, size: .m, variantId: "V1").value
        await vm.add(product: product, size: .m, variantId: "V1").value

        #expect(vm.totalPrice == 30.00)
    }

    @Test func currencyComesFromFirstCartItem() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1", currency: "USD"), size: .m, variantId: "V1").value

        #expect(vm.currency == "USD")
    }

    // MARK: Quantity changes

    @Test func increaseQuantityAddsOne() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1"), size: .m, variantId: "V1").value

        let item = try #require(vm.items.first)
        await vm.increaseQuantity(item).value

        #expect(vm.itemCount == 2)
    }

    @Test func decreaseQuantityAboveOneDecrementsCount() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        let product = makeProduct(id: "P1")
        await vm.add(product: product, size: .m, variantId: "V1").value
        await vm.add(product: product, size: .m, variantId: "V1").value

        let item = try #require(vm.items.first)
        await vm.decreaseQuantity(item).value

        #expect(vm.itemCount == 1)
        #expect(vm.items.count == 1)
    }

    @Test func decreaseQuantityFromOneRemovesItem() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1"), size: .m, variantId: "V1").value

        let item = try #require(vm.items.first)
        await vm.decreaseQuantity(item).value

        #expect(vm.items.isEmpty)
        #expect(vm.itemCount == 0)
    }

    // MARK: Remove items

    @Test func removeItemDeletesItFromCart() async throws {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1"), size: .m, variantId: "V1").value
        await vm.add(product: makeProduct(id: "P2"), size: .s, variantId: "V1").value

        let item = try #require(vm.items.first)
        await vm.remove(item).value

        #expect(vm.items.count == 1)
    }

    @Test func onDeleteRemovesItemsAtGivenIndexSet() async {
        let vm = CartViewModel(repository: MockCartRepository())

        await vm.add(product: makeProduct(id: "P1"), size: .m, variantId: "V1").value
        await vm.add(product: makeProduct(id: "P2"), size: .s, variantId: "V1").value

        await vm.onDelete(IndexSet([0])).value

        #expect(vm.items.count == 1)
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
}

// MARK: - Helpers

fileprivate func makeProduct(
    id: String = UUID().uuidString,
    price: Decimal = 10.00,
    currency: String = "EUR"
) -> Product {
    Product(
        productId: id,
        name: "Test Product",
        brand: "Test Brand",
        productDescription: "Test Description",
        category: .shirt,
        price: price,
        currency: currency,
        variants: [
            ProductVariant(id: "V1", colorName: "Black", colorHex: "#000000", imageURLs: [], availableSizes: [.s, .m, .l])
        ]
    )
}

fileprivate final class FailingCartRepository: CartRepositoryProtocol {
    struct CartError: Error {}
    func fetchItems() async throws -> [CartItem] { throw CartError() }
    func add(product: Product, size: ProductSize, variantId: String) async throws { throw CartError() }
    func updateQuantity(_ item: CartItem, to quantity: Int) async throws { throw CartError() }
    func remove(_ item: CartItem) async throws { throw CartError() }
    func clear() async throws { throw CartError() }
}
