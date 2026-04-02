//
//  ProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let modelContext: ModelContext
    private let upsertActor: ProductUpsertActor
    private let remoteDataSource: any RemoteDataSourceProtocol

    init(modelContainer: ModelContainer, remoteDataSource: any RemoteDataSourceProtocol) {
        self.modelContext = modelContainer.mainContext
        self.upsertActor = ProductUpsertActor(modelContainer: modelContainer)
        self.remoteDataSource = remoteDataSource
    }

    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) {
        let response = try await remoteDataSource.fetchPage(skip: skip, limit: limit)
        let snapshots = response.asSnapshots()
        try await upsertActor.upsert(snapshots)
        let products = try fetchByProductIds(snapshots.map(\.productId))
        return (products, response.total)
    }

    func fetchAll() async throws -> [Product] {
        let response = try await remoteDataSource.fetchAll()
        try await upsertActor.upsert(response.asSnapshots())
        return try modelContext.fetch(FetchDescriptor<Product>())
    }

    func fetch(category: ProductCategory?) async throws -> [Product] {
        let all = try await fetchAll()
        guard let category else { return all }
        return all.filter { $0.category == category }
    }

    func fetchProduct(id: String) async throws -> Product? {
        let snapshot = try await remoteDataSource.fetchProduct(id: id).asSnapshot()
        try await upsertActor.upsert([snapshot])
        return try fetchByProductIds([id]).first
    }

    func clearCache() throws {
        try modelContext.delete(model: CartItem.self)
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
        products.map { $0.asSnapshot() }
    }
}

extension ProductDTO {
    func asSnapshot() -> ProductSnapshot {
        ProductSnapshot(
            productId: String(id),
            sku: sku,
            title: title,
            brand: brand ?? "Generic",
            productDescription: description,
            category: ProductCategory(rawValue: category) ?? .miscellaneous,
            price: Decimal(price),
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            tags: tags,
            thumbnail: thumbnail,
            images: images
        )
    }
}
