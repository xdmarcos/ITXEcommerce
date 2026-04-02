//
//  ProductUpsertActorTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import SwiftData
import Testing

@Suite("ProductUpsertActor")
@MainActor
struct ProductUpsertActorTests {

    // MARK: Insert

    @Test func upsertInsertsNewProduct() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)

        try await actor.upsert([makeSnapshot(id: "1")])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 1)
        #expect(stored.first?.productId == "1")
    }

    @Test func upsertInsertsMultipleNewProducts() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)
        let snapshots = ["1", "2", "3"].map { makeSnapshot(id: $0) }

        try await actor.upsert(snapshots)

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 3)
    }

    @Test func upsertEmptyArrayChangesNothing() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)

        try await actor.upsert([])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.isEmpty)
    }

    // MARK: Update

    @Test func upsertUpdatesExistingProductTitle() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)
        try await actor.upsert([makeSnapshot(id: "1", title: "Old Title")])

        try await actor.upsert([makeSnapshot(id: "1", title: "New Title")])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 1)
        #expect(stored.first?.title == "New Title")
    }

    @Test func upsertUpdatesExistingProductStock() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)
        try await actor.upsert([makeSnapshot(id: "1", stock: 5)])

        try await actor.upsert([makeSnapshot(id: "1", stock: 99)])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.first?.stock == 99)
    }

    @Test func upsertUpdatesExistingProductPrice() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)
        try await actor.upsert([makeSnapshot(id: "1", price: 10.00)])

        try await actor.upsert([makeSnapshot(id: "1", price: 29.99)])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.first?.price == 29.99)
    }

    // MARK: Mixed insert + update

    @Test func upsertHandlesMixedInsertAndUpdateInSameBatch() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)
        try await actor.upsert([makeSnapshot(id: "1", title: "Original")])

        try await actor.upsert([
            makeSnapshot(id: "1", title: "Updated"),
            makeSnapshot(id: "2", title: "New Product")
        ])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 2)
        let p1 = try #require(stored.first { $0.productId == "1" })
        let p2 = try #require(stored.first { $0.productId == "2" })
        #expect(p1.title == "Updated")
        #expect(p2.title == "New Product")
    }

    @Test func upsertPreservesProductIdUniqueness() async throws {
        let container = try makeContainer()
        let actor = ProductUpsertActor(modelContainer: container)

        try await actor.upsert([makeSnapshot(id: "1")])
        try await actor.upsert([makeSnapshot(id: "1")])
        try await actor.upsert([makeSnapshot(id: "1")])

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 1)
    }
}

// MARK: - Helpers

private extension ProductUpsertActorTests {

    func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Product.self, CartItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    func makeSnapshot(
        id: String = "1",
        title: String = "Test Product",
        category: ProductCategory = .beauty,
        price: Decimal = 9.99,
        stock: Int = 10
    ) -> ProductSnapshot {
        ProductSnapshot(
            productId: id,
            sku: "SKU-\(id)",
            title: title,
            brand: "Brand",
            productDescription: "Description",
            category: category,
            price: price,
            discountPercentage: 0,
            rating: 4.0,
            stock: stock,
            tags: [],
            thumbnail: "",
            images: []
        )
    }
}
