//
//  ProductRepositoryTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import SwiftData
import Testing

@Suite("ProductRepository")
@MainActor
struct ProductRepositoryTests {

    // MARK: fetchPage

    @Test func fetchPageReturnsProductsFromRemote() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2, 3])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(pageResult: dto))

        let (products, total) = try await repo.fetchPage(skip: 0, limit: 20)

        #expect(products.count == 3)
        #expect(total == 3)
    }

    @Test func fetchPagePersistsProductsToLocalStore() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(pageResult: dto))

        _ = try await repo.fetchPage(skip: 0, limit: 20)

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 2)
    }

    @Test func fetchPagePropagatesRemoteError() async throws {
        let container = try makeContainer()
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(error: RemoteStubError()))

        await #expect(throws: RemoteStubError.self) {
            _ = try await repo.fetchPage(skip: 0, limit: 20)
        }
    }

    @Test func fetchPageRespectsSkipAndLimit() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [3, 4], total: 10)
        let remote = MockRemoteDataSource(pageResult: dto)
        let repo = ProductRepository(modelContainer: container, remoteDataSource: remote)

        let (products, total) = try await repo.fetchPage(skip: 2, limit: 2)

        #expect(products.count == 2)
        #expect(total == 10)
        #expect(remote.lastPageSkip == 2)
        #expect(remote.lastPageLimit == 2)
    }

    // MARK: fetchAll

    @Test func fetchAllReturnsAllProductsFromRemote() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2, 3, 4, 5])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))

        let products = try await repo.fetchAll()

        #expect(products.count == 5)
    }

    @Test func fetchAllPropagatesRemoteError() async throws {
        let container = try makeContainer()
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(error: RemoteStubError()))

        await #expect(throws: RemoteStubError.self) {
            _ = try await repo.fetchAll()
        }
    }

    // MARK: fetchProduct

    @Test func fetchProductReturnsMatchingProduct() async throws {
        let container = try makeContainer()
        let dto = makeProductDTO(id: 42, title: "Fancy Watch")
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(productResult: dto))

        let product = try await repo.fetchProduct(id: "42")

        let result = try #require(product)
        #expect(result.productId == "42")
        #expect(result.title == "Fancy Watch")
    }

    @Test func fetchProductUpdatesExistingProductInStore() async throws {
        let container = try makeContainer()
        let initial = makeProductDTO(id: 7, title: "Old Title")
        let updated = makeProductDTO(id: 7, title: "New Title")
        let remote = MockRemoteDataSource(productResult: initial)
        let repo = ProductRepository(modelContainer: container, remoteDataSource: remote)

        _ = try await repo.fetchProduct(id: "7")
        remote.productResult = .success(updated)
        _ = try await repo.fetchProduct(id: "7")

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.count == 1)
        #expect(stored.first?.title == "New Title")
    }

    @Test func fetchProductPropagatesRemoteError() async throws {
        let container = try makeContainer()
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(error: RemoteStubError()))

        await #expect(throws: RemoteStubError.self) {
            _ = try await repo.fetchProduct(id: "1")
        }
    }

    // MARK: fetch(category:)

    @Test func fetchWithNilCategoryFetchesFromRemote() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))

        let products = try await repo.fetch(category: nil as ProductCategory?)

        #expect(products.count == 2)
    }

    @Test func fetchWithCategoryFiltersLocalStore() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2, 3], categories: [ProductCategory.beauty, .beauty, .laptops])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))
        _ = try await repo.fetchAll()

        let beautyProducts = try await repo.fetch(category: ProductCategory.beauty)

        #expect(beautyProducts.count == 2)
        #expect(beautyProducts.allSatisfy { $0.category == .beauty })
    }

    @Test func fetchWithCategoryReturnsEmptyWhenNoneMatch() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1], categories: [ProductCategory.laptops])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))
        _ = try await repo.fetchAll()

        let result = try await repo.fetch(category: ProductCategory.beauty)

        #expect(result.isEmpty)
    }

    // MARK: clearCache

    @Test func clearCacheRemovesAllProducts() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1, 2, 3])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))
        _ = try await repo.fetchAll()

        try repo.clearCache()

        let stored = try container.mainContext.fetch(FetchDescriptor<Product>())
        #expect(stored.isEmpty)
    }

    @Test func clearCacheDoesNotRemoveCartItems() async throws {
        let container = try makeContainer()
        let dto = makeProductsDTO(ids: [1])
        let repo = ProductRepository(modelContainer: container, remoteDataSource: MockRemoteDataSource(allResult: dto))
        _ = try await repo.fetchAll()
        let product = try #require(try container.mainContext.fetch(FetchDescriptor<Product>()).first)
        container.mainContext.insert(CartItem(product: product))
        try container.mainContext.save()

        try repo.clearCache()

        let cartItems = try container.mainContext.fetch(FetchDescriptor<CartItem>())
        #expect(cartItems.count == 1)
    }
}

// MARK: - Helpers

private extension ProductRepositoryTests {

    func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Product.self, CartItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    func makeProductsDTO(
        ids: [Int],
        categories: [ProductCategory]? = nil,
        total: Int? = nil
    ) -> ProductsDTO {
        let products = ids.enumerated().map { index, id in
            makeProductDTO(id: id, category: categories?[index] ?? .beauty)
        }
        return ProductsDTO(products: products, total: total ?? ids.count, skip: 0, limit: ids.count)
    }

    func makeProductDTO(
        id: Int,
        title: String = "Product \(arc4random())",
        category: ProductCategory = .beauty
    ) -> ProductDTO {
        ProductDTO(
            id: id,
            title: title,
            description: "Description",
            category: category.rawValue,
            price: 9.99,
            discountPercentage: 0,
            rating: 4.0,
            stock: 10,
            tags: [],
            brand: "Brand",
            sku: "SKU-\(id)",
            weight: 1,
            dimensions: Dimensions(width: 1, height: 1, depth: 1),
            warrantyInformation: "",
            shippingInformation: "",
            availabilityStatus: "In Stock",
            reviews: [],
            returnPolicy: "",
            minimumOrderQuantity: 1,
            meta: Meta(createdAt: "", updatedAt: "", barcode: "", qrCode: ""),
            thumbnail: "",
            images: []
        )
    }

    struct RemoteStubError: Error, Equatable {}
}
