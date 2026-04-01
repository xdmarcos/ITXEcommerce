//
//  ProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import CoreNetwork
import Foundation
import SwiftData

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let modelContext: ModelContext
    private let upsertActor: ProductUpsertActor
    private let apiClient: ApiClientProtocol = ApiClient()

    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
        self.upsertActor = ProductUpsertActor(modelContainer: modelContainer)
    }

    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) {
        do {
            let response = try await apiClient.asyncRequest(
                endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: limit, skip: skip)),
                responseModel: ProductsDTO.self
            )
            let snapshots = response.asSnapshots()
            try await upsertActor.upsert(snapshots)
            let products = try fetchByProductIds(snapshots.map(\.productId))
            return (products, response.total)
        } catch {
            let mocks = Product.mockProducts
            return (Array(mocks.dropFirst(skip).prefix(limit)), mocks.count)
        }
    }

    func fetchAll() async throws -> [Product] {
        do {
            let response = try await apiClient.asyncRequest(
                endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: 0, skip: nil)),
                responseModel: ProductsDTO.self
            )
            try await upsertActor.upsert(response.asSnapshots())
            return try modelContext.fetch(FetchDescriptor<Product>())
        } catch {
            return Product.mockProducts
        }
    }

    func fetch(category: ProductCategory?) async throws -> [Product] {
        guard let category else { return try await fetchAll() }
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.category == category }
        )
        return try modelContext.fetch(descriptor)
    }

    func clearCache() throws {
        try modelContext.delete(model: Product.self)
        try modelContext.save()
    }

    private func fetchByProductIds(_ productIds: [String]) throws -> [Product] {
        try modelContext.fetch(
            FetchDescriptor<Product>(predicate: #Predicate { productIds.contains($0.productId) })
        )
    }
}

extension ProductsDTO {
    func asSnapshots() -> [ProductSnapshot] {
        products.map { dto in
            ProductSnapshot(
                productId: String(dto.id),
                sku: dto.sku,
                title: dto.title,
                brand: dto.brand ?? "Generic",
                productDescription: dto.description,
                category: ProductCategory(rawValue: dto.category) ?? .miscellaneous,
                price: Decimal(dto.price),
                discountPercentage: dto.discountPercentage,
                rating: dto.rating,
                stock: dto.stock,
                tags: dto.tags,
                thumbnail: dto.thumbnail,
                images: dto.images
            )
        }
    }
}
