//
//  CartRepositoryTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import SwiftData
import Testing

@Suite("CartRepository")
@MainActor
struct CartRepositoryTests {

    // MARK: fetchItems

    @Test func fetchItemsReturnsEmptyInitially() throws {
        let container = try makeContainer()
        let repo = CartRepository(modelContext: container.mainContext)

        let items = try repo.fetchItems()

        #expect(items.isEmpty)
    }

    // MARK: add

    @Test func addInsertsNewCartItem() throws {
        let container = try makeContainer()
        let product = makeProduct()
        container.mainContext.insert(product)
        let repo = CartRepository(modelContext: container.mainContext)

        try repo.add(product: product)

        let items = try repo.fetchItems()
        #expect(items.count == 1)
        #expect(items.first?.product?.productId == product.productId)
        #expect(items.first?.quantity == 1)
    }

    @Test func addIncrementsQuantityForExistingProduct() throws {
        let container = try makeContainer()
        let product = makeProduct()
        container.mainContext.insert(product)
        let repo = CartRepository(modelContext: container.mainContext)
        try repo.add(product: product)

        try repo.add(product: product)

        let items = try repo.fetchItems()
        #expect(items.count == 1)
        #expect(items.first?.quantity == 2)
    }

    @Test func addTwoDifferentProductsCreatesTwoItems() throws {
        let container = try makeContainer()
        let p1 = makeProduct(id: "1")
        let p2 = makeProduct(id: "2")
        container.mainContext.insert(p1)
        container.mainContext.insert(p2)
        let repo = CartRepository(modelContext: container.mainContext)

        try repo.add(product: p1)
        try repo.add(product: p2)

        let items = try repo.fetchItems()
        #expect(items.count == 2)
    }

    // MARK: updateQuantity

    @Test func updateQuantityChangesItemQuantity() throws {
        let container = try makeContainer()
        let product = makeProduct()
        container.mainContext.insert(product)
        let repo = CartRepository(modelContext: container.mainContext)
        try repo.add(product: product)
        let item = try #require(try repo.fetchItems().first)

        try repo.updateQuantity(item, to: 5)

        #expect(item.quantity == 5)
    }

    // MARK: remove

    @Test func removeDeletesItem() throws {
        let container = try makeContainer()
        let product = makeProduct()
        container.mainContext.insert(product)
        let repo = CartRepository(modelContext: container.mainContext)
        try repo.add(product: product)
        let item = try #require(try repo.fetchItems().first)

        try repo.remove(item)

        #expect(try repo.fetchItems().isEmpty)
    }

    @Test func removeOnlyDeletesTargetItem() throws {
        let container = try makeContainer()
        let p1 = makeProduct(id: "1")
        let p2 = makeProduct(id: "2")
        container.mainContext.insert(p1)
        container.mainContext.insert(p2)
        let repo = CartRepository(modelContext: container.mainContext)
        try repo.add(product: p1)
        try repo.add(product: p2)
        let item1 = try #require(try repo.fetchItems().first { $0.product?.productId == "1" })

        try repo.remove(item1)

        let remaining = try repo.fetchItems()
        #expect(remaining.count == 1)
        #expect(remaining.first?.product?.productId == "2")
    }

    // MARK: clear

    @Test func clearRemovesAllItems() throws {
        let container = try makeContainer()
        let p1 = makeProduct(id: "1")
        let p2 = makeProduct(id: "2")
        container.mainContext.insert(p1)
        container.mainContext.insert(p2)
        let repo = CartRepository(modelContext: container.mainContext)
        try repo.add(product: p1)
        try repo.add(product: p2)

        try repo.clear()

        #expect(try repo.fetchItems().isEmpty)
    }

    @Test func clearOnEmptyCartSucceeds() throws {
        let container = try makeContainer()
        let repo = CartRepository(modelContext: container.mainContext)

        #expect(throws: Never.self) {
            try repo.clear()
        }
    }
}

// MARK: - Helpers

private extension CartRepositoryTests {

    func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Product.self, CartItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    func makeProduct(id: String = "1", stock: Int = 10) -> Product {
        Product(
            productId: id,
            sku: "SKU-\(id)",
            title: "Product \(id)",
            brand: "Brand",
            productDescription: "Description",
            category: .beauty,
            price: 9.99,
            stock: stock
        )
    }
}
